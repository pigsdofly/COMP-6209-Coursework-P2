package q1;
import java.util.ArrayList;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.IOException;

public aspect CallGraph {
    ArrayList nodes = new ArrayList();
    ArrayList edges = new ArrayList();
    
    String node_file = "q1-nodes.csv";
    String edge_file = "q1-edges.csv";
    
    pointcut graph_point(): call(public int *(int)) && within(q1..*);

    before(): graph_point() {
        // Add node matching the join point to list of nodes
        nodes.add(thisJoinPoint.getSignature());  
    };
        
    // If a node matching graph_point is called within a graph point
    before(): graph_point() && withincode(public int *(int)) {
        String edge_string = "";
            
        // Take last two nodes added to node list and put them in edge list
        edge_string = edge_string.concat(nodes.get(nodes.size()-2).toString()).concat("->").concat(nodes.get(nodes.size()-1).toString());
        edges.add(edge_string);
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
