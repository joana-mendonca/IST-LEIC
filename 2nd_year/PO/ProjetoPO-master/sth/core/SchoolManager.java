package sth.core;

import sth.core.exception.*;

import java.io.IOException;
import java.io.FileNotFoundException;
import java.lang.reflect.Array;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Iterator;


//FIXME import other classes if needed

/**
 * The façade class.
 */
public class SchoolManager {

    //FIXME add object attributes if needed

    private School _school;
    private Person _loggedUser;

    //FIXME implement constructors if needed
    public SchoolManager() {
        _school = new School();
    }

    /**
     * @param datafile
     * @throws ImportFileException
     * @throws InvalidCourseSelectionException
     */
    public void importFile(String datafile) throws ImportFileException {
        try {
            _school.importFile(datafile);
        } catch (IOException | BadEntryException e) {
            throw new ImportFileException(e);
        }
    }

    /**
     * Do the login of the user with the given identifier.
     *
     * @param id identifier of the user to login
     * @throws NoSuchPersonIdException if there is no uers with the given identifier
     */
    public void login(int id) throws NoSuchPersonIdException {
        //recebe id, procura  pessoa com esse id
        Iterator<Person> it = _school.getAllUsers().iterator();
        while (it.hasNext()) {
            if (it.next().getId() == id) {
                setLoggedUser(it.next());
                return;
            }
        }
        throw new NoSuchPersonIdException(id);
    }

    /**
     * @return true when the currently logged in person is an administrative
     */
    public boolean isLoggedUserAdministrative() {
        return getLoggedUser() instanceof Employee;
    }

    /**
     * @return true when the currently logged in person is a professor
     */
    public boolean isLoggedUserProfessor() {
        return getLoggedUser() instanceof Teacher;
    }

    /**
     * @return true when the currently logged in person is a student
     */
    public boolean isLoggedUserStudent() {
        return getLoggedUser() instanceof Student;
    }

    /**
     * @return true when the currently logged in person is a representative
     */
    public boolean isLoggedUserRepresentative() {
        if (isLoggedUserStudent()) {
            Student s = (Student) getLoggedUser();
            return s.isRepresentative();
        }
        return false;
    }

    /**
     * @returns the Person logged in
     */
    private Person getLoggedUser() {
        return _loggedUser;
    }

    /**
     * @param p introduces a person in the login
     */
    private void setLoggedUser(Person p) {
        _loggedUser = p;
    }

    /******************************************************************************************************************
     *  Portal Pessoa                                                                                                 *
     ******************************************************************************************************************/

    /**
     * @param number phone number of the user
     */
    public void changePhoneNumber(int number) {
        getLoggedUser().set_phoneNumber(number);
    }

    /**
     * @param str string introduced by LoggedUser
     * @return all people's names that are equal to the given string
     */
    public ArrayList<Person> searchPerson(String str) {
        Iterator<Person> it = _school.getAllUsers().iterator();
        ArrayList<Person> result = new ArrayList<>();
        while (it.hasNext()) {
            if (it.next().getName().contains(str))
                result.add(it.next());
        }
        result.sort(Comparator.comparing(Person::getName));
        return result;
    }

    /**
     * @return all registered users
     */
    public ArrayList<Person> getAllUsers() {
        ArrayList<Person> result = _school.getAllUsers();
        return result;
    }

    /**
     * @param id identifier of the person to show
     * @return the person's information from the giver identifier
     * @throws NoSuchPersonIdException if there's no such person with the given identifier
     */
    public Person showPerson(int id) throws NoSuchPersonIdException {
        Iterator<Person> it = _school.getAllUsers().iterator();
        while (it.hasNext()) {
            if (it.next().getId() == id)
                return it.next();
        }
        throw new NoSuchPersonIdException(id);
    }


    /******************************************************************************************************************
     *  Portal Docente                                                                                                *
     ******************************************************************************************************************/

    public void createProject(String disName, String projName) throws NoSuchDisciplineIdException {
        Teacher teacher = (Teacher) _loggedUser;
        try {
            teacher.createProject(disName, projName);
        } catch (NoSuchDisciplineIdException e) {
            throw e;
        }

    }


    public void closeProject(String disName, String projName) throws NoSuchProjectIdException, NoSuchDisciplineIdException {
        Teacher teacher = (Teacher) _loggedUser;
        try {
            teacher.closeProject(disName, projName);
        } catch (NoSuchDisciplineIdException e) {
            throw e;
        }
    }


    public ArrayList<Student> showDisciplineStudents(String discipline) throws NoSuchDisciplineIdException {
        Teacher teacher = (Teacher) _loggedUser;
        try {
            Discipline d = teacher.getDiscipline(discipline);
            return d.getEnrolledStudents();
        } catch (NoSuchDisciplineIdException e) {
            throw e;
        }
    }

}
