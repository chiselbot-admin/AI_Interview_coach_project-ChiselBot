package com.coach.chiselbot._global.config.loder;

import com.coach.chiselbot.domain.admin.Admin;
import com.coach.chiselbot.domain.admin.AdminRepository;
import com.coach.chiselbot.domain.interview_category.InterviewCategory;
import com.coach.chiselbot.domain.interview_category.InterviewCategoryRepository;
import com.coach.chiselbot.domain.interview_question.InterviewLevel;
import com.coach.chiselbot.domain.interview_question.InterviewQuestion;
import com.coach.chiselbot.domain.interview_question.InterviewQuestionRepository;
import com.coach.chiselbot.domain.interview_question.InterviewQuestionService;
import com.coach.chiselbot.domain.notice.Notice;
import com.coach.chiselbot.domain.notice.NoticeRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

@Component
@RequiredArgsConstructor
@Profile("local")
@Order(4)
public class QuestionLoader implements CommandLineRunner {

    private final InterviewQuestionRepository interviewQuestionRepository;
    private final InterviewCategoryRepository categoryRepository;
    private final AdminRepository adminRepository;

    @Override
    public void run(String... args) throws Exception {
        // 이미 데이터가 있다면 중복 삽입 방지

        Admin admin = adminRepository.findById(1L)
                .orElseThrow(() -> new IllegalStateException("Admin not found"));

        InterviewCategory category = categoryRepository.findById(4L)
                .orElseGet(() -> {
                    InterviewCategory newCategory = new InterviewCategory(4L, "Flutter");
                    return categoryRepository.save(newCategory);
                });

        List<InterviewQuestion> questionList = new ArrayList<>();
        for (int i = 1; i <= 21; i++) {
            InterviewQuestion question = InterviewQuestion.builder()
                    .categoryId(category)
                    .interviewLevel(InterviewLevel.LEVEL_1)
                    .adminId(admin)
                    .questionText("질문테스트 " +i)
                    .answerText("답변테스트 " +i)
                    .build();

            questionList.add(question);
        }

        interviewQuestionRepository.saveAll(questionList);
        System.out.println("더미 질문사항 11개가 등록되었습니다.");
    }
}
