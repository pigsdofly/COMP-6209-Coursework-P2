package q2;
import java.lang.Exception;

class main {
    public static void main(String[] args) throws Exception {
        A a = new A();
        a.foo(3);
        a.foo(0);
        a.foo(2);

        B b = new B();
        b.foo(1);
        b.foo(3);
        b.foo(1);
    }
}
