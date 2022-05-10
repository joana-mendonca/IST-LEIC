package pt.ulisboa.tecnico.socialsoftware.tutor.dashboard;

import java.util.List;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Isolation;
import org.springframework.transaction.annotation.Transactional;

import pt.ulisboa.tecnico.socialsoftware.tutor.answer.domain.QuestionAnswer;
import pt.ulisboa.tecnico.socialsoftware.tutor.answer.domain.QuizAnswer;
import pt.ulisboa.tecnico.socialsoftware.tutor.answer.repository.QuestionAnswerRepository;
import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.domain.Dashboard;
import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.domain.FailedAnswer;
import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.dto.FailedAnswerDto;
import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.repository.DashboardRepository;
import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.repository.FailedAnswerRepository;
import pt.ulisboa.tecnico.socialsoftware.tutor.exceptions.TutorException;
import pt.ulisboa.tecnico.socialsoftware.tutor.utils.DateHandler;
import pt.ulisboa.tecnico.socialsoftware.tutor.exceptions.ErrorMessage;

@Service
public class FailedAnswerService {
    
    @Autowired
    private QuestionAnswerRepository questionAnswerRepository;

    @Autowired
    private FailedAnswerRepository failedAnswerRepository;

    @Autowired
    private DashboardRepository dashboardRepository;


    @Transactional(isolation = Isolation.READ_COMMITTED)
    public FailedAnswerDto createFailedAnswer(int dashboardId, int questionAnswerId) {
        QuestionAnswer questionAnswer = questionAnswerRepository.findById(questionAnswerId)
                .orElseThrow(() -> new TutorException(ErrorMessage.QUESTION_ANSWER_NOT_FOUND));

        Dashboard dashboard = dashboardRepository.findById(dashboardId)
                .orElseThrow(() -> new TutorException(ErrorMessage.DASHBOARD_NOT_FOUND));

        for (FailedAnswer failedAnswer : failedAnswerRepository.findAll()) {
            if (failedAnswer.getQuestionAnswer().getId().equals(questionAnswerId)) {
                throw new TutorException(ErrorMessage.FAILED_ANSWER_ALREADY_CREATED);
            }
        }
        FailedAnswer newFailedAnswer = new FailedAnswer(dashboard, questionAnswer, DateHandler.now());
        failedAnswerRepository.save(newFailedAnswer);
        return new FailedAnswerDto(newFailedAnswer);
    }


    @Transactional(isolation = Isolation.READ_COMMITTED)
    public void removeFailedAnswer(int failedAnswerId) {
        FailedAnswer toRemove = failedAnswerRepository.findById(failedAnswerId)
                                .orElseThrow(() -> new TutorException(ErrorMessage.FAILED_ANSWER_NOT_FOUND, failedAnswerId));

        toRemove.remove();
        failedAnswerRepository.delete(toRemove);
    }

    
    @Transactional(isolation = Isolation.READ_COMMITTED)
    public List<FailedAnswerDto> getFailedAnswers(int dashboardId) {
        Dashboard dashboard = dashboardRepository.findById(dashboardId)
            .orElseThrow(() -> new TutorException(ErrorMessage.DASHBOARD_NOT_FOUND, dashboardId));

        List<FailedAnswerDto> failedAnswerDtos = dashboard.getFailedAnswers()
                                              .stream()
                                              .map((failedAnswer) -> new FailedAnswerDto(failedAnswer))
                                              .sorted(FailedAnswerDto.COLLECTED_COMPARATOR)
                                              .collect(Collectors.toList());

        return failedAnswerDtos;
    }


    @Transactional(isolation = Isolation.READ_COMMITTED)
    public void updateFailedAnswers(Integer dashboardId, String startDateString, String endDateString) {
        Dashboard dashboard = dashboardRepository.findById(dashboardId)
            .orElseThrow(() -> new TutorException(ErrorMessage.DASHBOARD_NOT_FOUND, dashboardId));
            
        boolean waitingForPublicQuizResults = false;
        LocalDateTime startDate = null;

        if (startDateString != null) {
            startDate = LocalDateTime.parse(startDateString, DateTimeFormatter.ISO_DATE_TIME);
        }
        else {
            startDate = dashboard.getLastCheckFailedAnswers();
        } 
        LocalDateTime endDate = null;
        if (endDateString != null) {
            endDate = LocalDateTime.parse(endDateString, DateTimeFormatter.ISO_DATE_TIME);
        }
        for (QuizAnswer answer : dashboard.getStudent().getQuizAnswers()) {
            if (!answer.canResultsBePublic(dashboard.getCourseExecution().getId())) {
                // lastCheck must remain on the first quiz we're waiting for
                if (!waitingForPublicQuizResults) {
                    dashboard.setLastCheckFailedAnswers(answer.getCreationDate().minusSeconds(1));
                }
                waitingForPublicQuizResults = true;
                continue;
            }
            if ((startDate != null && !answer.getCreationDate().isAfter(startDate)) || 
                (endDate   != null && !answer.getCreationDate().isBefore(endDate))) {
                continue;
            }
            answer.getQuestionAnswers()
                  .stream()
                  .forEach((questionAnswer) -> tryNewFailedAnswer(dashboard, questionAnswer));
        }
        if (!waitingForPublicQuizResults) {
            dashboard.setLastCheckFailedAnswers(DateHandler.now());
        }
    }


    /**
     * Creates a failed answer, catching TutorExceptions silently. To be used in updateFailedAnswers,
     * where throwing an exception upon failing to create a FailedAnswer is undesirable.
     */
    private void tryNewFailedAnswer(Dashboard dashboard, QuestionAnswer questionAnswer) {
        for (FailedAnswer failedAnswer : failedAnswerRepository.findAll()) {
            if (failedAnswer.getQuestionAnswer().getId().equals(questionAnswer.getId())) {
                return;
            }
        }
        try {
            FailedAnswer newFailedAnswer = new FailedAnswer(dashboard, questionAnswer, DateHandler.now());
            failedAnswerRepository.save(newFailedAnswer);
        }
        // fail silently if this Failed Answer cannot be created
        catch (TutorException e) {}
    }
}
