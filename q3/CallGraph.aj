package q2;
import java.util.ArrayList;
import java.util.HashMap;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.IOException;
import java.lang.Exception;

public aspect CallGraph {
    ArrayList nodes = new ArrayList();
    ArrayList edges = new ArrayList();
    // Structure of nested hash maps for histogram
    HashMap node_keys = new HashMap();
    
    String node_file = "q1-nodes.csv";
    String edge_file = "q1-edges.csv";
    
    pointcut graph_point(): call(public int *(int)) && within(q2..*);
    //pointcut graph_point(): execution(public int *(int)) && within(q1..*);

    after(int i) returning(int j): graph_point() && args(i) {
        nodes.add(thisJoinPoint.getSignature());  
        String jp_str = thisJoinPoint.getSignature().toString();
        if(!node_keys.containsKey(jp_str)) {
            node_keys.put(jp_str, new HashMap());
        } 
        
        addToMap(jp_str, Integer.valueOf(i), "arg");
        addToMap(jp_str, Integer.valueOf(j), "ret");
       /* System.out.println("Arg: ");
        System.out.println(i);
        System.out.println(" Returning: ");
        System.out.println(j); */
    };
        

    before(): graph_point() && withincode(public int *(int)) {
        String edge_string = "";
        
        edge_string = edge_string.concat(nodes.get(nodes.size()-2).toString()).concat("->").concat(nodes.get(nodes.size()-1).toString());
        edges.add(edge_string);
    };
    
    after() throwing (Exception e): graph_point() && withincode(public int * (int)) {
        System.out.println("Exception occured, removing latest edge");
        edges.remove(edges.size()-1);
    }

    after(): execution(public static void main(..)) {
        System.out.println(nodes);
        System.out.println(edges);
        System.out.println(node_keys);
        writeCsv(node_file, nodes);
        writeCsv(edge_file, edges);
    };

    //The histogram uses a structure of nested hashmaps, with the top layer containing a hashmap for each int value,
    //Which then contains a hashmap for the amount of times the int has been used as a return value or argument
    void addToMap(String signature, Integer i, String type) {
        HashMap temp_map = (HashMap) node_keys.get(signature);
        if(temp_map.containsKey(i)) {
            HashMap map_value = (HashMap) temp_map.get(i);
            Integer map_value_int = (Integer) map_value.get(type);
            int temp_int = map_value_int.intValue() + 1;
            //HashMap doesn't like non-object values so we have to convert to and from the Integer type
            map_value.replace(type, Integer.valueOf(temp_int));
            temp_map.replace(i, map_value);
        } else {
            HashMap map_value = new HashMap();
            map_value.put("arg", Integer.valueOf(0));
            map_value.put("ret", Integer.valueOf(0));
            map_value.replace(type, Integer.valueOf(1));
            temp_map.put(i, map_value);
            
        }
        node_keys.replace(signature, temp_map);
        
    }

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
