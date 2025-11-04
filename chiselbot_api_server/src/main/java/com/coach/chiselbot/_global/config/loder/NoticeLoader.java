package com.coach.chiselbot._global.config.loder;

import com.coach.chiselbot.domain.admin.Admin;
import com.coach.chiselbot.domain.admin.AdminRepository;
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
@Order(3)
public class NoticeLoader implements CommandLineRunner {

    private final NoticeRepository noticeRepository;
    private final AdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;
    private final Random random = new Random();

    @Override
    public void run(String... args) throws Exception {
        // 이미 데이터가 있다면 중복 삽입 방지
        if (noticeRepository.count() > 0) return;

        Admin admin = adminRepository.findById(1L)
                .orElseThrow(() -> new IllegalStateException("Admin not found"));

        List<Notice> notices = new ArrayList<>();
        for (int i = 1; i <= 11; i++) {
            Notice notice = Notice.builder()
                    .title("공지사항 제목 " + i)
                    .content(makeRandomContent(i))
                    .isVisible(random.nextBoolean())
                    .viewCount(random.nextInt(300))
                    .admin(admin)
                    .build();

            notices.add(notice);
        }

        noticeRepository.saveAll(notices);
        System.out.println("더미 공지사항 11개가 등록되었습니다.");
    }

    private String makeRandomContent(int i) {
        String[] samples = {
                "시스템 점검으로 인한 서비스 일시 중단 안내드립니다.",
                "신규 기능이 추가되었습니다. 자세한 내용은 공지사항을 참고해주세요.",
                "회원 약관이 일부 개정되어 공지드립니다.",
                "이벤트 참여에 감사드립니다. 다음 이벤트도 기대해주세요!",
                "보안 업데이트가 진행됩니다. 이용에 참고 바랍니다.",
                "주말 동안 일부 기능이 제한됩니다.",
                "정기 점검 일정이 변경되었습니다.",
                "서버 성능 향상 작업이 예정되어 있습니다.",
                "공지사항 테스트 데이터입니다.",
                "신규 회원 혜택이 추가되었습니다.",
                "개발 환경 테스트용 공지입니다."
        };
        return samples[random.nextInt(samples.length)] + "\n\n테스트 데이터 #" + i;
    }
}
