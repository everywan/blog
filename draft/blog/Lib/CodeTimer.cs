public static class CodeTimer
{
    public static void Initialize()
    {
        Process.GetCurrentProcess().PriorityClass = ProcessPriorityClass.High;
        Thread.CurrentThread.Priority = ThreadPriority.Highest;
        Time("", 1, () => { });
    }

    public static void Time(string name, int iteration, Action action)
    {
        if (String.IsNullOrEmpty(name)) return;

        // 1. 调整颜色输出
        ConsoleColor currentForeColor = Console.ForegroundColor;
        Console.ForegroundColor = ConsoleColor.Yellow;
        Console.WriteLine(name);

        // 2. 强制GC进行收集, 并记录目前各代已经收集的次数
        //强制在 GCCollectionMode 值所指定的模式对 0 代到指定代进行垃圾回收
        GC.Collect(GC.MaxGeneration, GCCollectionMode.Forced);
        int[] gcCounts = new int[GC.MaxGeneration + 1];
        for (int i = 0; i <= GC.MaxGeneration; i++)
        {
            //返回自启动进程以来已经对指定代进行的垃圾回收次数
            gcCounts[i] = GC.CollectionCount(i);
        }

        // 3. 执行代码, 记录下消耗的时间及CPU时钟周期
        Stopwatch watch = new Stopwatch();
        watch.Start();
        ulong cycleCount = GetCycleCount();
        for (int i = 0; i < iteration; i++) action();
        ulong cpuCycles = GetCycleCount() - cycleCount;
        watch.Stop();

        // 4. 恢复颜色输出, 并打印消耗时间及CPU时钟周期
        Console.ForegroundColor = currentForeColor;
        Console.WriteLine("\tTime Elapsed:\t" + watch.ElapsedMilliseconds.ToString("N0") + "ms");
        Console.WriteLine("\tCPU Cycles:\t" + cpuCycles.ToString("N0"));

        // 5. 印执行过程中各代垃圾收集回收次数
        for (int i = 0; i <= GC.MaxGeneration; i++)
        {
            int count = GC.CollectionCount(i) - gcCounts[i];
            Console.WriteLine("\tGen " + i + ": \t\t" + count);
        }

        Console.WriteLine();
    }
    
    private static ulong GetCycleCount()
    {
        ulong cycleCount = 0;
        QueryThreadCycleTime(GetCurrentThread(), ref cycleCount);
        return cycleCount;
    }

    [DllImport("kernel32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    static extern bool QueryThreadCycleTime(IntPtr threadHandle, ref ulong cycleTime);

    [DllImport("kernel32.dll")]
    static extern IntPtr GetCurrentThread();
}