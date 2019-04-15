package q2;
import java.util.ArrayList;
import java.util.HashMap;
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
    
    pointcut graph_point(): call(public int *(int)) && within(q2..*);
    //pointcut graph_point(): execution(public int *(int)) && within(q1..*);

    int around(int i): graph_point() && args(i) {
        try {
            
            if(!attempts.containsKey(thisJoinPoint.getSignature())) {
                attempts.put(thisJoinPoint.getSignature(), Integer.valueOf(1));
                failures.put(thisJoinPoint.getSignature(), Integer.valueOf(0));
            }
            else {
                Integer attempt_count = (Integer) attempts.get(thisJoinPoint.getSignature());
                attempts.replace(thisJoinPoint.getSignature(), Integer.valueOf(attempt_count.intValue() + 1));
            }
            
            int result = proceed(i);
                
            
            return result;
        } catch(Exception e) {
            Integer fail_count = (Integer) failures.get(thisJoinPoint.getSignature());
            failures.replace(thisJoinPoint.getSignature(), Integer.valueOf(fail_count.intValue() + 1));
            return -1;
        }
    }

    after(): execution(public static void main(..)) {
        
        System.out.println(attempts);
        System.out.println(failures);
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
