package sth.app.exception;

import pt.tecnico.po.ui.DialogException;

public class NoSuchFileException extends DialogException {
    /** Serial number for serialization. */
    private static final long serialVersionUID = 201810051538L;

    /** File name. */
    private String _file;

    /**
     * @param file
     */
    public NoSuchFileException(String file) {
        _file = file;
    }

    /** @see pt.tecnico.po.ui.DialogException#getMessage() */
    @Override
    public String getMessage() {
        return Message.noSuchFile(_file);
    }
}
