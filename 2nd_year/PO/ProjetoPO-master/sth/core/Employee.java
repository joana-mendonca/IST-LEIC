package sth.core;

public class Employee extends Person{

    public Employee(int id, int phoneNumber, String name){
        super(id, phoneNumber, name);
    }

    @Override
    public String toString(){
        return "FUNCIONÁRIO|" + super.toString();
    }
}

