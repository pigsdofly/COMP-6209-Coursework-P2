//Compiled with -1.5 flag to force java version 1.5 (higher than default for ajc on my laptop)
package q2.slp1n18;
import java.util.ArrayList;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.IOException;
import java.lang.Exception;

public aspect Q2 {
    ArrayList nodes = new ArrayList();
    ArrayList edges = new ArrayList();
    
    String node_file = "q2-nodes.csv";
    String edge_file = "q2-edges.csv";
    
    pointcut graph_point(): call(public int *(int)) && within(q2..*);

    before(): graph_point() {
        nodes.add(thisJoinPoint.getSignature());  
    };
        
    before(): graph_point() && withincode(public int *(int)) {
        // Adding new entries to edges must be done before function execution
        String edge_string = "";
            
        edge_string = edge_string.concat(nodes.get(nodes.size()-2).toString()).concat(",").concat(nodes.get(nodes.size()-1).toString());

        edges.add(edge_string);

    };
    
    // after throwing block to avoid interfering with program logic
    after() throwing(Exception e): graph_point() && withincode(public int * (int)) {
        System.out.println("An exception occurred");
        edges.remove(edges.size()-1);
    };

    after(): execution(public static void main(..)) {
        writeCsv(node_file, nodes, "node,\n");
        writeCsv(edge_file, edges, "source method, target method,\n");
        System.out.println("Files q2-nodes.csv and q2-edges.csv written.");
    };

    void writeCsv(String filename, ArrayList list, String init_string) {
        try {
            FileWriter node_out = new FileWriter(filename,false);
            PrintWriter node_print = new PrintWriter(node_out);
            node_print.printf(init_string);
            for(int i = 0; i < list.size(); i++) {
                node_print.println(list.get(i)+",");
            }
            node_print.close();
        } catch(IOException e) {
            System.out.println("IO error");        
        }
    }
}
