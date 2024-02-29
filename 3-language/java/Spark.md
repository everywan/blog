# Spark
1. SparkContext: Java代码与Spark集群的主要交互接口
2. RDD: 弹性分布式数据集, 可以在多台机器上分布执行
3. 对于Spark程序, 如果提交任务到spark执行(使用spark命令提交任务), 则spark会读取自己lib下的jar包，而不会从`/META-INF/MANIFEST.MF`读取引用的依赖包. 此时,可以用jar方式执行spark程序,不过要做以下更改:
    ```Java
    SparkConf sc = new SparkConf().setMaster("local[2]").setAppName("test");
    JavaSparkContext jc = new JavaSparkContext(sc);
    ```
## 版本
1. 1.6.0版本: SparkConf
2. 2.1.0: SparkContent
### 示例
1. 功能: 从文件中读取车辆停放点数据(args[0]), 从mongo中读取地铁站位置信息, 统计每个地铁站网格中停放点数量.
```Java
public class Main {
    public static void main(String[] args){

        final String mgohost = "172.26.10.20";

        if (args.length < 2) {
            System.out.println("params data.csv");
            return;
        }

        String input = args[0];
        String city = args[1];
        String date_in = args[2];
//        // Spark2.1
//        SparkSession spark = SparkSession.builder()
//                .appName("subwaydata")
//                .config("spark.mongodb.output.uri", "mongodb://spark:spark@" + mgohost + ":27017/admin")
//                .config("spark.mongodb.output.database","mobike")
//                .config("spark.mongodb.output.collection","subway_rank_index")
//                .config("spark.mongodb.input.uri","mongodb://spark:spark@" + mgohost + ":27017/admin")
//                .config("spark.mongodb.input.database","mobike")
//                .config("spark.mongodb.input.collection","subwayinfo")
//                .config("spark.mongodb.input.partitioner","MongoSamplePartitioner")
//                .getOrCreate();
//
//        JavaSparkContext jc = new JavaSparkContext(spark.sparkContext());
//        Dataset<Row> dataset = spark.read().format("com.mongodb.spark.sql.DefaultSource").load()
//                .select("area","name").toDF("area","name");
//        Map<String,String> subwayInfo = new HashMap<>();
//        for (Row _line: dataset.collectAsList()) {
//            subwayInfo.put(_line.getString(0),_line.getString(1));
//        }

        // spark1.6
        SparkConf sc = new SparkConf()
                .setAppName("subwaydata")
                .set("spark.mongodb.input.uri", "mongodb://spark:spark@"+mgohost+":27017/admin")
                .set("spark.mongodb.input.database","mobike")
                .set("spark.mongodb.input.collection","subwayinfo")
                .set("spark.mongodb.output.uri", "mongodb://spark:spark@"+mgohost+":27017/admin")
                .set("spark.mongodb.output.database","mobike")
                .set("spark.mongodb.output.collection","subway_rank_index")
                .set("spark.mongodb.input.partitioner","MongoSamplePartitioner");
        JavaSparkContext jc = new JavaSparkContext(sc);
        JavaRDD<String> spotInfo = jc.textFile(input);

        Dataset<Row> dataset = MongoSpark.load(jc).toDF();

        Map<String,String> subwayInfo = new HashMap<>();
        for (Row _line: dataset.collectAsList()) {
            subwayInfo.put(_line.getString(1),_line.getString(2));
        }
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        DateTimeFormatter formatter2 = DateTimeFormatter.ofPattern("yyyy/MM/dd");
        final String date = LocalDate.parse(date_in,formatter2).format(formatter);

        JavaPairRDD<String,ODCountEntity> javaPairRDD = spotInfo.mapToPair(new PairFunction<String, String, ODCountEntity>() {
            @Override
            public Tuple2<String, ODCountEntity> call(String s) {
                try {
                    ODCountEntity odCountEntity = new ODCountEntity();
                    String[] str = s.split(",");
                    String o = getTileNumber(Double.parseDouble(String.valueOf(str[3])),
                            Double.parseDouble(String.valueOf(str[2])), 18);
                    String d = getTileNumber(Double.parseDouble(String.valueOf(str[6])),
                            Double.parseDouble(String.valueOf(str[5])), 18);
                    odCountEntity.setDCount(0);
                    odCountEntity.setOCount(0);
                    String grid = "error";
                    if(subwayInfo.containsKey(o)){
                        grid = o;
                        odCountEntity.setOCount(1);
                    }
                    if(subwayInfo.containsKey(d)){
                        grid = d;
                        odCountEntity.setOCount(1);
                    }
                    return new Tuple2<>(grid,odCountEntity);
                }catch (Exception e){

                }
                return new Tuple2<>("error",new ODCountEntity());
            }
        }).filter(new Function<Tuple2<String, ODCountEntity>, Boolean>() {
            @Override
            public Boolean call(Tuple2<String, ODCountEntity> stringODCountEntityTuple2) throws Exception {
                if(stringODCountEntityTuple2._1.equals("error"))
                    return false;
                return true;
            }
        }).reduceByKey(new Function2<ODCountEntity, ODCountEntity, ODCountEntity>() {
            @Override
            public ODCountEntity call(ODCountEntity od1, ODCountEntity od2) throws Exception {
                ODCountEntity result = new ODCountEntity();
                result.setOCount(od1.getOCount()+od2.getOCount());
                result.setDCount(od1.getDCount()+od2.getDCount());
                return result;
            }
        });

        JavaRDD<Document> javaRDD = javaPairRDD.map(new Function<Tuple2<String, ODCountEntity>, Document>() {
            @Override
            public Document call(Tuple2<String, ODCountEntity> in) throws Exception {
                try {
                    Document doc = new Document();
                    doc.put("city",city);
                    doc.put("date",date);
                    doc.put("grid",in._1());
                    doc.put("ocount",in._2().getOCount());
                    doc.put("dcount",in._2().getDCount());
                    doc.put("name",subwayInfo.get(in._1()));
                    return doc;
                }catch (Exception e){}
                Document doc2=new Document();
                doc2.put("error","");
                return doc2;
            }
        }).filter(new Function<Document, Boolean>() {
            @Override
            public Boolean call(Document doc) throws Exception {
                if(doc.containsKey("error"))
                    return false;
                return true;
            }
        });
        MongoSpark.save(javaRDD);
        jc.stop();
    }
    public static String getTileNumber(final double lat, final double lon, final int zoom) {
        int xtile = (int)Math.floor( (lon + 180) / 360 * (1<<zoom) ) ;
        int ytile = (int)Math.floor( (1 - Math.log(Math.tan(Math.toRadians(lat)) + 1 / Math.cos(Math.toRadians(lat))) / Math.PI) / 2 * (1<<zoom) ) ;
        if (xtile < 0)
            xtile=0;
        if (xtile >= (1<<zoom))
            xtile=((1<<zoom)-1);
        if (ytile < 0)
            ytile=0;
        if (ytile >= (1<<zoom))
            ytile=((1<<zoom)-1);
        return(xtile + "-" + ytile);
    }
}
```