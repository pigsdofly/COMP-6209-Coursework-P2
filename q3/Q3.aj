package q3;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.IOException;

import java.lang.Exception;

public aspect Q3 {

    HashMap times = new HashMap();
    
    // Structure of nested hash maps for histogram
    HashMap node_keys = new HashMap();
    
    // Hash maps for failures
    HashMap attempts = new HashMap();
    HashMap failures = new HashMap();

    pointcut graph_point(): call(public int *(int)) && within(q3..*);

    int around(int i): graph_point() && args(i) {
        String joinpoint_name = thisJoinPoint.getSignature().toString();
        
        if(!attempts.containsKey(joinpoint_name)) {
            attempts.put(joinpoint_name, 1);
            failures.put(joinpoint_name, 0);
        }
        else {
            int attempt_count = getIntFromObject(attempts.get(joinpoint_name));
            attempts.replace(joinpoint_name, attempt_count + 1);
        }
        
        long start = System.nanoTime();
        int result = proceed(i);
        long end = System.nanoTime();
        runtimeProfiling(joinpoint_name, start, end);
        
        histogramConstruction(joinpoint_name, i, result);
            
        return result;
            
    }
    
    //Adding failures split off into separate block from around block
    after() throwing(Exception e): graph_point() && withincode(public int * (int)) {
        System.out.println("Exception caught");
        String joinpoint_name = thisJoinPoint.getSignature().toString();
        int fail_count = getIntFromObject(failures.get(joinpoint_name));
        failures.replace(joinpoint_name, fail_count + 1);
        
    }
    
    void runtimeProfiling(String joinpoint_name, long start, long end) {
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
    }
    
    void histogramConstruction(String joinpoint_name, int arg, int result) {
        if(!node_keys.containsKey(joinpoint_name)) {
            node_keys.put(joinpoint_name, new HashMap());
        } 
        
        addToMap(joinpoint_name, arg, "arg");
        addToMap(joinpoint_name, result, "ret");
    }

    //The histogram uses a structure of nested hashmaps, with the top layer containing a hashmap for each int value,
    //Which then contains a hashmap for the amount of times the int has been used as a return value or argument
    void addToMap(String signature, Integer i, String type) {
        HashMap temp_map = (HashMap) node_keys.get(signature);
        if(temp_map.containsKey(i)) {
            HashMap map_value = (HashMap) temp_map.get(i);
            int temp_int = getIntFromObject(map_value.get(type));
            map_value.replace(type, temp_int + 1);
            temp_map.replace(i, map_value);
        } else {
            HashMap map_value = new HashMap();
            map_value.put("arg", 0);
            map_value.put("ret", 0);
            map_value.replace(type, 1);
            temp_map.put(i, map_value);
        }
        node_keys.replace(signature, temp_map);
        
    }
    
    // All the csv making logic split off into separate functions
    after(): execution(public static void main(..)) {
        histogramCsv();
        failureCsv();
        runtimeCsv();
    };
    
    void histogramCsv() {
        Iterator hist_iter = node_keys.entrySet().iterator();

        while(hist_iter.hasNext()) {
            String csv_output = "Value, Times Input, Times Output, \n";
            Map.Entry entry = (Map.Entry) hist_iter.next();
            String signature = (String) entry.getKey();
            HashMap inner = (HashMap) entry.getValue();
            Iterator inner_iter = inner.entrySet().iterator();
            while(inner_iter.hasNext()) {
                Map.Entry inner_entry = (Map.Entry) inner_iter.next();
                HashMap arg_ret = (HashMap) inner_entry.getValue();
                int arg = getIntFromObject(arg_ret.get("arg"));
                int ret = getIntFromObject(arg_ret.get("ret"));
                
                int val = getIntFromObject(inner_entry.getKey());
                String formatted_string = String.format("%d, %d, %d,\n", val, arg, ret );
                csv_output += formatted_string;
                inner_iter.remove();
            }
            
            writeCsv(signature+".csv", csv_output);
            
            hist_iter.remove();
        }
    }
    
    void failureCsv() {
        double fail_rate;
        
        Iterator failure_iter = failures.entrySet().iterator();
        String csv_output = "Method, Failure Rate (Percent),\n";

        while (failure_iter.hasNext()) {
            Map.Entry entry = (Map.Entry) failure_iter.next();
            String signature = (String) entry.getKey();

            int fail_val = getIntFromObject(entry.getValue());
            fail_rate = 0.0;

            if (fail_val!= 0) {
                int attempt_val = getIntFromObject(attempts.get(signature));
                fail_rate = ((double) fail_val / (double) attempt_val)*100;
            }

            String formatted_string = String.format("%s, %f,\n", signature, fail_rate);
            csv_output += formatted_string;
            failure_iter.remove();
        }
        
        writeCsv("failures.csv", csv_output);
    }    

    void runtimeCsv() {
        Iterator time_iter = times.entrySet().iterator();
        String csv_output = "Method, Mean (milliseconds), Std. Dev (milliseconds),\n";

        while(time_iter.hasNext()) {
            Map.Entry entry = (Map.Entry) time_iter.next();

            double mean = averageTimes((ArrayList) entry.getValue());
            double std_dev = stdDevTimes((ArrayList) entry.getValue(), mean);

            // Converts from nanoseconds to milliseconds by dividing by 1000000
            String formatted_string = String.format("%s, %f, %f,\n", 
                         (String) entry.getKey(), (mean / 1000000), (std_dev / 1000000));
            csv_output += formatted_string;
            time_iter.remove();
        }

        writeCsv("runtimes.csv", csv_output);
    }

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

    //Utility function to make retrieving int values from hashmaps and arraylists less of a hassle
    int getIntFromObject(Object object) {
        return ((Integer) object).intValue();
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

    void writeCsv(String filename, String output) {
        try {
            FileWriter node_out = new FileWriter(filename,false);
            PrintWriter node_print = new PrintWriter(node_out);
            node_print.printf(output);
            node_print.close();
            System.out.println("Created file "+filename);
        } catch(IOException e) {
            System.out.println("IO error");        
        }
    }

}
