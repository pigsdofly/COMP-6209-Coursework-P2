package q3;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.IOException;

import java.lang.Exception;

public aspect Failure {
    ArrayList nodes = new ArrayList();
    ArrayList edges = new ArrayList();
    // Structure of nested hash maps for histogram
    HashMap attempts = new HashMap();
    HashMap failures = new HashMap();
    
    pointcut graph_point(): call(public int *(int)) && within(q3..*);

    int around(int i): graph_point() && args(i) {
        String joinpoint_name = thisJoinPoint.getSignature().toString();
        try {
            
            if(!attempts.containsKey(joinpoint_name)) {
                attempts.put(joinpoint_name, 1);
                failures.put(joinpoint_name, 0);
            }
            else {
                int attempt_count = getIntFromObject(attempts.get(joinpoint_name));
                attempts.replace(joinpoint_name, attempt_count + 1);
            }
            
            int result = proceed(i);
                
            return result;
            
        } catch(Exception e) {
            int fail_count = getIntFromObject(failures.get(joinpoint_name));
            failures.replace(joinpoint_name, fail_count + 1);
            return -1;
        }
    }

    int getIntFromObject(Object object) {
        return ((Integer) object).intValue();
    }

    after(): execution(public static void main(..)) {
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
        
        try {
            FileWriter node_out = new FileWriter("failures.csv", false);
            PrintWriter node_print = new PrintWriter(node_out);
            node_print.printf(csv_output);
            node_print.close();
            System.out.println("Failure information printed to failures.csv");
        } catch(IOException e) {
            System.out.println("IO error (failures.csv)");
        }
                
    };


    void writeCsv(String filename, ArrayList list) {
        try {
            FileWriter node_out = new FileWriter(filename,false);
            PrintWriter node_print = new PrintWriter(node_out);
            for(int i = 0; i < list.size(); i++) {
                node_print.println(list.get(i)+",");
            }
            node_print.close();
        } catch(IOException e) {
            System.out.println("IO error");        
        }
    }
}
