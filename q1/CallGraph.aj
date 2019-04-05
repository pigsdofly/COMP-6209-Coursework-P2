package q1;
import java.util.ArrayList;

public aspect CallGraph {
    ArrayList nodes = new ArrayList();
    ArrayList edges = new ArrayList();
    
    pointcut graph_point(): call(public int *(int)) && within(q1..*);
    //pointcut graph_point(): execution(public int *(int)) && within(q1..*);

    before(): graph_point() {
        nodes.add(thisJoinPoint.getSignature());  
    };
        
    before(): graph_point() && withincode(public int *(int)) {
        String edge_string = "";
        
        edge_string = edge_string.concat(nodes.get(nodes.size()-2).toString()).concat("->").concat(nodes.get(nodes.size()-1).toString());
        edges.add(edge_string);
    };
    

    after(): execution(public static void main(..)) {
        System.out.println(nodes);
        System.out.println(edges);
    };
}
