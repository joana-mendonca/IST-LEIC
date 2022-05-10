package pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.dto;
import pt.ulisboa.tecnico.socialsoftware.tutor.answer.dto.QuestionAnswerDto;
import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.domain.FailedAnswer;

import java.io.Serializable;
import java.util.Comparator;

public class FailedAnswerDto implements Serializable {

    private Integer id;

    private boolean answered;

    private String collected;

    private QuestionAnswerDto questionAnswerDto;

    public static FailedAnswerDtoComparator COLLECTED_COMPARATOR = new FailedAnswerDtoComparator();

    public FailedAnswerDto(FailedAnswer answer) {
        setId(answer.getId());
        setAnswered(answer.getAnswered());
        setCollected(answer.getCollected().toString());
        setQuestionAnswerDto(new QuestionAnswerDto(answer.getQuestionAnswer()));
    }

    public Integer getId() {
        return id;
    }

    public Boolean getAnswered() {
        return answered;
    }

    public String getCollected() {
        return collected;
    }

    public QuestionAnswerDto getQuestionAnswerDto() {
        return questionAnswerDto;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public void setAnswered(Boolean answered) {
        this.answered = answered;
    }

    public void setQuestionAnswerDto(QuestionAnswerDto questionAnswerDto) {
        this.questionAnswerDto = questionAnswerDto;
    }

    public void setCollected(String collected) {
        this.collected = collected;
    }

    @Override
    public String toString() {
        return "FailedAnswerDto{" +
                "id=" + id +
                ", answered=" + answered +
                "}";
    }

    private static class FailedAnswerDtoComparator implements Comparator<FailedAnswerDto> {
        
        @Override
        public int compare(FailedAnswerDto FA1, FailedAnswerDto FA2) {
            return FA2.getCollected().compareTo(FA1.getCollected());
        }
    }
}