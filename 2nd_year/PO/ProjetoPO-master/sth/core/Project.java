package sth.core;

import java.util.HashMap;

public class Project {
    private String _name;
    private String _description;
    private boolean _closed;
    private Discipline _discipline;
    private HashMap<Integer, Submission> _submissions;
    private Survey _survey;

    public Project(String _name, String _description, Discipline _discipline) {
        this._name = _name;
        this._description = _description;
        this._discipline = _discipline;
        _submissions = new HashMap<>();
        _closed = false;
        _survey = null;
    }

    public String get_name() {
        return _name;
    }

    public void close(){
        _closed = true;
    }

    public Survey get_survey() {
        return _survey;
    }

    public void addSubmission(Student st, String msg){
        Submission sub = new Submission(msg);
        _submissions.put(st.getId(), sub);
        st.SubmitProject(this, sub);
    }

    public HashMap<Integer, Submission> get_submissions() {
        return _submissions;
    }
}