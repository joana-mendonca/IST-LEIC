package pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.domain;

import pt.ulisboa.tecnico.socialsoftware.tutor.exceptions.ErrorMessage;
import pt.ulisboa.tecnico.socialsoftware.tutor.exceptions.TutorException;
import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.domain.DifficultQuestion;
import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.DifficultQuestionService;
import pt.ulisboa.tecnico.socialsoftware.tutor.impexp.domain.DomainEntity;
import pt.ulisboa.tecnico.socialsoftware.tutor.impexp.domain.Visitor;
import pt.ulisboa.tecnico.socialsoftware.tutor.utils.DateHandler;

import java.time.LocalDateTime;

import javax.persistence.*;
import java.util.*;

 
@Entity
public class SameDifficulty implements DomainEntity {

	@Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @OneToOne
    private DifficultQuestion difficultQuestion;

    @OneToMany
    private Set<DifficultQuestion> difficultQuestions = new HashSet<>();


    public SameDifficulty(DifficultQuestion diffQuestion) {

        if (diffQuestion == null) {
            throw new TutorException(ErrorMessage.DIFFICULT_QUESTION_IS_NULL);
        } 

        for (DifficultQuestion diff : diffQuestion.getDashboard().getDifficultQuestions()) {

            if (diff.getPercentage() == diffQuestion.getPercentage()) {

                if (diff.getId() != diffQuestion.getId()) {

                    difficultQuestions.add(diffQuestion);

                }
            }

        }

    }

    public void remove(DifficultQuestion diffQuestion) {

        this.difficultQuestions.clear();
        diffQuestion.remove();
    }


    public void accept(Visitor visitor) {
    }


}