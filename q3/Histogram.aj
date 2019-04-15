package q2;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.IOException;

import java.lang.Exception;

public aspect Histogram {
    // Structure of nested hash maps for histogram
    HashMap node_keys = new HashMap();
    
    
    pointcut graph_point(): call(public int *(int)) && within(q2..*);
    //pointcut graph_point(): execution(public int *(int)) && within(q1..*);

    int around(int i): graph_point() && args(i) {
        try {
            int result = proceed(i);
                
            String jp_str = thisJoinPoint.getSignature().toString();
            if(!node_keys.containsKey(jp_str)) {
                node_keys.put(jp_str, new HashMap());
            } 
            
            addToMap(jp_str, i, "arg");
            addToMap(jp_str, result, "ret");
            
            return result;
        } catch(Exception e) {
            return -1;
        }
    }

    after(): execution(public static void main(..)) {
        System.out.println(node_keys);
        
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
    };

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
    
    //Utility function to make retrieving int values from hashmaps and arraylists less of a hassle
    int getIntFromObject(Object object) {
        return ((Integer) object).intValue();
    }
}
