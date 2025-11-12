package com.coach.chiselbot._global.config.loder;


import com.coach.chiselbot._global.errors.exception.Exception404;
import com.coach.chiselbot.domain.Inquiry.Inquiry;
import com.coach.chiselbot.domain.Inquiry.InquiryRepository;
import com.coach.chiselbot.domain.Inquiry.InquiryStatus;
import com.coach.chiselbot.domain.admin.Admin;
import com.coach.chiselbot.domain.admin.AdminRepository;
import com.coach.chiselbot.domain.answer.Answer;
import com.coach.chiselbot.domain.answer.AnswerRepository;
import com.coach.chiselbot.domain.user.User;
import com.coach.chiselbot.domain.user.UserJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;

@Component
@RequiredArgsConstructor
@Profile("dev")
@Order(3)
public class InquiryDataLoader implements CommandLineRunner {

    private final InquiryRepository inquiryRepository;
    private final UserJpaRepository userJpaRepository;
    private final AnswerRepository answerRepository;
    private final AdminRepository adminRepository;

    @Override
    public void run(String... args) throws Exception {

        Admin admin = adminRepository.findByEmail("admin@chisel.com")
                .orElseThrow(() -> new Exception404("해당 관리자를 찾을 수 없습니다."));


        List<User> users = userJpaRepository.findAll();
        if (users.isEmpty()) return; // 유저 없을 때 생략

        Timestamp now = Timestamp.from(Instant.now());

        Inquiry inquiry = inquiryRepository.save(
                Inquiry.builder()
                        .user(users.get(0))
                        .title("결제 환불 요청")
                        .content("결제 후 사용하지 않아 환불 요청드립니다.")
                        .status(InquiryStatus.ANSWERED)
                        .build()
        );

        Inquiry inquiry2 = inquiryRepository.save(
                Inquiry.builder()
                        .user(users.get(1))
                        .title("기능 제안")
                        .content("AI 추천 기능에 이력서 분석 기능을 추가해주셨으면 합니다.")
                        .status(InquiryStatus.ANSWERED)
                        .build()
        );

        Inquiry inquiry3 = inquiryRepository.save(
                Inquiry.builder()
                        .user(users.get(2))
                        .title("AI 답변 지연시간")
                        .content("답변 지연 시간이 긴 것 같습니다.저만 그런걸까요ㅠㅠ")
                        .status(InquiryStatus.ANSWERED)
                        .build()
        );


        Answer answer1 = Answer.builder()
                .inquiry(inquiry)
                .admin(admin)
                .content("좋은 제안 감사합니다. 다음 업데이트에 검토 예정입니다 🙏")
                .build();

        inquiry.setAnswer(answer1);
        answerRepository.save(answer1);

        Answer answer2 = Answer.builder()
                .inquiry(inquiry2)
                .admin(admin)
                .content("좋은 제안 감사합니다. 다음 업데이트에 검토 예정입니다 🙏")
                .build();

        inquiry2.setAnswer(answer2);
        answerRepository.save(answer2);

        Answer answer3 = Answer.builder()
                .inquiry(inquiry3)
                .admin(admin)
                .content("좋은 제안 감사합니다. 다음 업데이트에 검토 예정입니다 🙏")
                .build();

        inquiry3.setAnswer(answer3);
        answerRepository.save(answer3);
    }
}
