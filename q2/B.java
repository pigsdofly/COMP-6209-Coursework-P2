package q2.slp1n18;
import java.lang.Exception;

public class B {
    public int foo(int a) throws Exception {
        bar(a);
        return 0;
    }

    public int bar(int b) throws Exception {
        if(b == 1) {
            throw new Exception("bad thing");
        }
        return baz(b);
    }

    public int baz(int a) {
        return a + a;
    }
    
}
