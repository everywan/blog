# coding:utf-8
"""
    多线程,多进程,线程池,进程池学习与实践
"""
import urllib2

def worker(url):
    resp = urllib2.urlopen(url)
    print resp.url
    data = resp.readline()
    resp.close()
    return data

def threadBase():
    '创建线程'
    import threading
    # 定义线程列表, 参数详细见 Thread 的 __init__ 方法
    # 注意: args=(arg,): 加逗号表示参数只有arg一个; 不加逗号 如果arg可拆分则将arg拆成数组作为一堆参数传入(如string会被拆成一堆char,当成len个参数传入)
    threads = [threading.Thread(target=worker,args=(arg,)) for arg in ["http://www.zhihu.com","http://www.baidu.com"]]
    for thread in threads:
        # 启动线程
        thread.start()
    for thread in threads:
        # t.join()方法阻塞调用此方法的线程(calling thread), 直到线程t完. 此线程再继续; 通常用于在main()主线程内, 等待其它线程完成再结束main()主线程
        thread.join()

def threadPoolDemo():
    '线程池示例'
    import threadpool
    # 创建线程数
    pool = threadpool.ThreadPool(2)
    # 添加任务, 参数为: 开启多线程的函数, 相关参数, 回调函数
    requests = threadpool.makeRequests(worker,["https://www.zhihu.com","http://www.baidu.com"])
    # 将任务放到线程池去执行
    [pool.putRequest(req) for req in requests]
    # 主线程等待所有线程完成任务 
    pool.wait()

def multiProcess():
    '多进程示例'
    import multiprocessing
    # 获取CPU计数
    cpu_cnt = multiprocessing.cpu_count()
    results = []
    # 初始化进程池
    pool = multiprocessing.Pool(cpu_cnt)
    for url in ["http://www.zhihu.com","http://www.baidu.com"]:
        # 添加任务
        # apply: 顺序执行子进程(主进程等待), 可以直接获取执行结果而不需要等待. (内部实现: 调用 apply_async().get())
        # apply_async: 异步执行, 进程执行完毕后(即 join() 后)才可以通过get()方法获取返回值
        result = pool.apply_async(worker,(url,))
        print result
        # 保存进程返回的 结果(class对象,使用 get() 获取)
        results.append(result)
    # 关闭进程池, 即当前线程池不会再放入新的任务, 且一旦所有任务完成, 工作进程将退出
    pool.close()
    # 进程合并. 使用方法类似Java里的join. 不过Python中需要在 join() 前调用 close() 或 terminate()
    pool.join()
    print [results[index].get() for index in range(0,2)]

def futuresDemo():
    'concurrent.futures: https://docs.python.org/3/library/concurrent.futures.html'
    import concurrent.futures
    # 线程池
    # with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
    # 进程池
    with concurrent.futures.ProcessPoolExecutor(max_workers=2) as executor:
        # submit(fn,*args,**kwargs): 将fn方法安排为可执行, 返回Future对象
        results = {executor.submit(worker,url) for url in ["http://www.zhihu.com","http://www.baidu.com"]}
        # as_completed(fs,timeout): 当线程/进程执行完毕时,返回由fs给出的Future实例的迭代器
        for result in concurrent.futures.as_completed(results):
            # result(): 返回进程方法执行的结果. 如果进程没有完成, 如果没有超时就等待, 如果超时则 raise concurrent.futures.TimeoutError.
            print result.result()

def futuresDemo_Map():
    'concurrent.futures: map版本'
    import concurrent.futures
    with concurrent.futures.ProcessPoolExecutor(max_workers=2) as executor:
        # map(func, *iterables,chunksize): chunksize 表示初始数据块大小(3.5以后版本支持),ThreadPoolExecutor设置chunksize无效
        # 返回值: 以参数传入的顺序返回执行结果的迭代器, as_completed()是乱序返回的(内部调用的submit执行任务,但是返回时按参数传入顺序排序)
        for result in executor.map(worker,[url for url in ["http://www.zhihu.com","http://www.baidu.com"]]):
            print result

if __name__ == "__main__":
    # threadBase()
    # threadPoolDemo()
    multiProcess()
    # futuresDemo()
    # futuresDemo_Map()