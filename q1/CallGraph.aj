package q1;

public aspect CallGraph {
    before(): call( public int q1..*(int) ) {
        System.out.println("hi");  
    };
}
