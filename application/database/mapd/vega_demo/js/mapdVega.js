var testVega = {
    "width": 1000,
    "height": 500,
    "data": [
        {
            "name": "stellitedb",
            "sql": "select lon as x,lat as y,rowid from stellitedb limit 10000000",
        }
    ],
    "scales": [
        {
            "name": "x",
            "type": "linear",
            "domain": [
                -180.00000000000000,
                180.00000000000000
            ],
            "range": "width",
        },
        {
            "name": "y",
            "type": "linear",
            "domain": [
                -90.00000000000000,
                90.00000000000000
            ],
            "range": "height",
        }
    ],
    "marks": [
        {
            "type": "points",
            "from": {
                "data": "stellitedb",
            },
            "properties": {
                "x": {
                    "scale": "x",
                    "field": "x",
                },
                "y": {
                    "scale": "y",
                    "field": "y",
                },
                "fillColor": "#00A1F1",
                "size": {
                    "value": 1
                },
            },
        },
    ]
};

var alert_testVega = function(){
    
}
