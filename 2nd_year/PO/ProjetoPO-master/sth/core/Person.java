package sth.core;

// add imports later

import sth.core.exception.BadEntryException;

/**
 * Person implementation.
 */
public abstract class Person {
	private int _id;
	private String _name;
	private int _phoneNumber;

    public Person(int _id, int _phoneNumber, String _name) {
        this._id = _id;
        this._name = _name;
        this._phoneNumber = _phoneNumber;
    }

    public String getName(){
		return _name;
	}

	public Integer getId(){
		return _id;
	}

    public void set_phoneNumber(int _phoneNumber) {
        this._phoneNumber = _phoneNumber;
    }

    @Override
    public String toString() {
        return "" + _id + "|" + _phoneNumber + "|" + _name;
    }

    /**
     * Parses the context information for a person from the import file.
     * This method defines the default behavior: no extra information is needed
     * thus it throws the exception.
     **/
    void parseContext(String context, School school) throws BadEntryException {
        throw new BadEntryException("Should not have extra context: " + context);
    }
}