package q3;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.IOException;

import java.lang.Exception;


public aspect Runtime {
    // Structure of nested hash maps for histogram
    HashMap times = new HashMap();
    
    
    pointcut graph_point(): call(public int *(int)) && within(q3..*);

    int around(int i): graph_point() && args(i) {
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
    }

    after(): execution(public static void main(..)) {
        Iterator time_iter = times.entrySet().iterator();
        String csv_output = "Method, Mean (milliseconds), Std. Dev (milliseconds),\n";
        while(time_iter.hasNext()) {
            Map.Entry entry = (Map.Entry) time_iter.next();

            double mean = averageTimes((ArrayList) entry.getValue());
            double std_dev = stdDevTimes((ArrayList) entry.getValue(), mean);

            // Converts from nanoseconds to milliseconds by dividing by 1000000
            String formatted_string = String.format("%s, %f, %f,\n", (String) entry.getKey(), (mean / 1000000), (std_dev / 1000000));
            csv_output += formatted_string;
            time_iter.remove();
        }

        try {
            FileWriter node_out = new FileWriter("runtimes.csv",false);
            PrintWriter node_print = new PrintWriter(node_out);
            node_print.printf(csv_output);
            node_print.close();
            System.out.println("Program runtimes written to runtimes.csv");
        } catch(IOException e) {
            System.out.println("IO error (runtimes.csv)");        
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
