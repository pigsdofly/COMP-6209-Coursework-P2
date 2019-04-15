package q2;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Timer;

import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.IOException;

import java.lang.Exception;


public aspect Runtime {
    // Structure of nested hash maps for histogram
    HashMap times = new HashMap();
    
    
    pointcut graph_point(): call(public int *(int)) && within(q2..*);
    //pointcut graph_point(): execution(public int *(int)) && within(q1..*);

    int around(int i): graph_point() && args(i) {
        try {
            String joinpoint_name = thisJoinPoint.getSignature().toString();
            long start = System.nanoTime();
            int result = proceed(i);
            long end = System.nanoTime();
            int time = (int) (end - start);
            if(!times.containsKey(joinpoint_name)) {
                ArrayList temp_list = new ArrayList();
                temp_list.add(time);
                times.put(joinpoint_name, temp_list);
            }
            else {
                ArrayList temp_list = (ArrayList) times.get(joinpoint_name);
                temp_list.add(time);
                times.replace(joinpoint_name, temp_list);
            }
            
            return result;
        } catch(Exception e) {
            return -1;
        }
    }

    after(): execution(public static void main(..)) {
        System.out.println(times.get("int q2.A.foo(int)"));
        Iterator timesIter = times.entrySet().iterator();
        String csv_output = "Method, Mean, St Dev,\n";
        while(timesIter.hasNext()) {
            Map.Entry entry = (Map.Entry) timesIter.next();
            System.out.println(entry.getKey() + " " + entry.getValue());
            double mean = averageTimes((ArrayList) entry.getValue());
            double std_dev = stdDevTimes((ArrayList) entry.getValue(), mean);
            String formatted_string = String.format("%s, %f, %f,\n", (String) entry.getKey(), mean, std_dev);
            csv_output += formatted_string;
            timesIter.remove();
        }

        try {
            FileWriter node_out = new FileWriter("runtimes.csv",false);
            PrintWriter node_print = new PrintWriter(node_out);
            node_print.printf(csv_output);
            node_print.close();
        } catch(IOException e) {
            System.out.println("IO error");        
        }
        
    };

    double averageTimes(ArrayList time) {
        if (time.size() == 1) {
            
            return ((Integer) time.get(0)).intValue();
        }
        double sum = 0;
        for (int i = 0; i < time.size(); i++) {
            int x = ((Integer) time.get(i)).intValue();
            sum += x;
        }
        return (sum / time.size());
    }

    double stdDevTimes(ArrayList time, double mean) {
        if (time.size() == 1) {
            return 0;
        }
        double sum = 0;
        for (int i = 0; i < time.size(); i++) {
            int x = ((Integer) time.get(i)).intValue();
            double std_dev =(long) Math.pow((x - mean), 2);
            sum += std_dev;
        }
        return Math.sqrt(sum / time.size());
    }

}
