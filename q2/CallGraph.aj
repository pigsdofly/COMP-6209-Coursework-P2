package q2;
import java.util.ArrayList;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.IOException;
import java.lang.Exception;

public aspect CallGraph {
    ArrayList nodes = new ArrayList();
    ArrayList edges = new ArrayList();
    
    String node_file = "q1-nodes.csv";
    String edge_file = "q1-edges.csv";
    
    pointcut graph_point(): call(public int *(int)) && within(q2..*);
    //pointcut graph_point(): execution(public int *(int)) && within(q1..*);

    before(): graph_point() {
        nodes.add(thisJoinPoint.getSignature());  
    };
        
    int around(): graph_point() && withincode(public int *(int)) {
        try {
            // Adding new entries to edges must be done before function execution
            String edge_string = "";
                
            edge_string = edge_string.concat(nodes.get(nodes.size()-2).toString()).concat("->").concat(nodes.get(nodes.size()-1).toString());

            edges.add(edge_string);
            result = proceed();
            return result;

        } catch(Exception e) {
            //If an exception happens, remove the bad edge from edges
            System.out.println("An exception occurred");
            edges.remove(edges.size()-1);
            return -1;
        }   
    };

    after(): execution(public static void main(..)) {
        System.out.println(nodes);
        System.out.println(edges);
        writeCsv(node_file, nodes);
        writeCsv(edge_file, edges);
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
