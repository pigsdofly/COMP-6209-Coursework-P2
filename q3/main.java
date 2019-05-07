package q3.slp1n18;
import java.lang.Exception;

class main {
    public static void main(String[] args) throws Exception {
        A a = new A();
        a.foo(3);
        a.foo(0);
        a.foo(2);

        B b = new B();
        try {
            b.foo(1);
        } catch(Exception e) {
        }
        try {
            b.foo(3);
        } catch(Exception e) {
        }
          
        try{
            b.foo(1);
        } catch(Exception e) {
        }
    }
}
