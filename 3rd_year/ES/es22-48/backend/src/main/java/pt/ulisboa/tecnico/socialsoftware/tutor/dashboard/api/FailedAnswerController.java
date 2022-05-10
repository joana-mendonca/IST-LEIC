package pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.api;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.FailedAnswerService;
import pt.ulisboa.tecnico.socialsoftware.tutor.dashboard.dto.FailedAnswerDto;

@RestController
public class FailedAnswerController {
    @Autowired
    FailedAnswerService failedAnswerService;

    FailedAnswerController(FailedAnswerService failedAnswerService) {
        this.failedAnswerService = failedAnswerService;
    }

    @GetMapping("/students/dashboards/{dashboardId}/failedAnswers")
    @PreAuthorize("hasRole('ROLE_STUDENT') and hasPermission(#dashboardId, 'DASHBOARD.ACCESS')")
    public List<FailedAnswerDto> getFailedAnswers(@PathVariable int dashboardId) {
        return failedAnswerService.getFailedAnswers(dashboardId);
    }

    @DeleteMapping("/students/dashboards/{dashboardId}/failedAnswers/{failedAnswerId}")
    @PreAuthorize("hasRole('ROLE_STUDENT') and hasPermission(#dashboardId, 'DASHBOARD.ACCESS')")
    public void removeFailedAnswer(@PathVariable int dashboardId, @PathVariable Integer failedAnswerId){
        failedAnswerService.removeFailedAnswer(failedAnswerId);
    }

    @PutMapping("/students/dashboards/{dashboardId}")
    @PreAuthorize("hasRole('ROLE_STUDENT') and hasPermission(#dashboardId, 'DASHBOARD.ACCESS')")
    public void updateFailedAnswers(@PathVariable int dashboardId){
        failedAnswerService.updateFailedAnswers(dashboardId, null, null);
    }
}
