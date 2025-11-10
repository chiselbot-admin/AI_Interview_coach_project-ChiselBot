package com.coach.chiselbot.domain.Inquiry;

import com.coach.chiselbot._global.errors.adminException.AdminException404;
import com.coach.chiselbot._global.errors.exception.Exception400;
import com.coach.chiselbot._global.errors.exception.Exception403;
import com.coach.chiselbot._global.errors.exception.Exception404;
import com.coach.chiselbot.domain.Inquiry.dto.InquiryRequestDTO;
import com.coach.chiselbot.domain.Inquiry.dto.InquiryResponseDTO;
import com.coach.chiselbot.domain.user.User;
import com.coach.chiselbot.domain.user.UserJpaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.IntStream;

@Service
@RequiredArgsConstructor
@Transactional
public class InquiryService {

    private final InquiryRepository inquiryRepository;
    private final UserJpaRepository userJpaRepository;

    /**
     * 관리자 문의 상세 조회 처리
     */
    public InquiryResponseDTO.AdminInquiryDetail getAdminInquiryDetail(Long inquiryId) {
        Inquiry inquiry = inquiryRepository.findByIdWithAnswer(inquiryId)
                .orElseThrow(() -> new AdminException404("해당 문의를 찾을 수 없습니다."));

        return InquiryResponseDTO.AdminInquiryDetail.from(inquiry);
    }

    /**
     * 관리자 리스트 조회 처리
     */
    public List<InquiryResponseDTO.AdminInquiryList> adminInquiryList() {
        List<Inquiry> inquiries = inquiryRepository.findAllWithUserAnswer();

        return IntStream.range(0, inquiries.size())
                .mapToObj(i -> {
                    Inquiry inquiry = inquiries.get(i);
                    InquiryResponseDTO.AdminInquiryList dto =
                            InquiryResponseDTO.AdminInquiryList.from(inquiry);
                    dto.setDisplayNumber(i + 1);

                    return dto;
                })
                .toList();
    }

    /**
     * 사용자 문의 삭제 처리
     */
    public void deleteInquiry(Long inquiryId, String userEmail) {
        User user = userJpaRepository.findByEmail(userEmail)
                .orElseThrow(() -> new Exception404("사용자를 찾을 수 업습니다."));

        Inquiry inquiry = inquiryRepository.findById(inquiryId)
                .orElseThrow(() -> new Exception404("해당 문의를 찾을 수 없습니다."));

        if (!inquiry.getUser().equals(user)) {
            throw new Exception403("본인만 문의를 삭제할 수 있습니다.");
        }

        if (inquiry.getStatus() != InquiryStatus.WAITING) {
            throw new Exception400("대기 상태의 문의만 삭제할 수 있습니다.");
        }

        inquiryRepository.delete(inquiry);
    }


    /**
     * 사용자 문의 수정 처리
     */
    public Inquiry updateInquiry(Long inquiryId, InquiryRequestDTO.Update dto, String userEmail) {
        User user = userJpaRepository.findByEmail(userEmail)
                .orElseThrow(() -> new Exception404("사용자를 찾을 수 없습니다."));

        Inquiry inquiry = inquiryRepository.findById(inquiryId)
                .orElseThrow(() -> new Exception404("해당 문의를 찾을 수 없습니다."));

        if (!inquiry.getUser().equals(user)) {
            throw new Exception403("본인만 문의를 수정할 수 있습니다.");
        }

        if (inquiry.getStatus() != InquiryStatus.WAITING) {
            throw new Exception400("대기 상태의 문의만 수정할 수 있습니다.");
        }

        inquiry.setTitle(dto.getTitle());
        inquiry.setContent(dto.getContent());

        return inquiry;
    }

    /**
     * 사용자 문의 상세 조회 처리
     */
//    public InquiryResponseDTO.UserInquiryDetail finById(Long id) {
//        Inquiry inquiry = inquiryRepository.findById(id)
//                .orElseThrow(() -> new Exception404("해당 문의를 찾을 수 없습니다."));
//        return InquiryResponseDTO.UserInquiryDetail.from(inquiry);
//    }

    // 미답변된 문의도 상세 볼 수 있도록
    public InquiryResponseDTO.UserInquiryDetail finById(Long id) {
        Inquiry inquiry = inquiryRepository.findByIdWithAnswer(id)
                .orElseThrow(() -> new Exception404("해당 문의를 찾을 수 없습니다."));
        return InquiryResponseDTO.UserInquiryDetail.from(inquiry);
    }

    /**
     * 사용자 문의 목록 조회 처리
     */
    public Page<InquiryResponseDTO.UserInquiryList> findInquiries(Pageable pageable) {
        Page<Inquiry> inquiries = inquiryRepository.findAll(pageable);
        return inquiries.map(InquiryResponseDTO.UserInquiryList::from);
    }

    /**
     * 사용자 문의 생성 처리
     */
    public Inquiry createInquiry(InquiryRequestDTO.Create dto, String userEmail) {

        User author = userJpaRepository.findByEmail(userEmail)
                .orElseThrow(() -> new Exception404("존재하지 않는 사용자입니다"));

        Inquiry newInquiry = new Inquiry();
        newInquiry.setTitle(dto.getTitle());
        newInquiry.setUser(author);
        newInquiry.setContent(dto.getContent());
        newInquiry.setStatus(InquiryStatus.WAITING);
        return inquiryRepository.save(newInquiry);
    }

//    // 위 메서드 테스트용
//    public Inquiry createInquiry(InquiryRequestDTO.Create dto, String userEmail) {
//        if (dto.getTitle() == null || dto.getTitle().isBlank()
//                || dto.getContent() == null || dto.getContent().isBlank()) {
//            throw new Exception400("제목/내용을 입력하세요.");
//        }
//
//        User author = (userEmail == null)
//                ? userJpaRepository.findById(1L)
//                .orElseThrow(() -> new Exception404("테스트 사용자(id=1)가 없습니다."))
//                : userJpaRepository.findByEmail(userEmail)
//                .orElseThrow(() -> new Exception404("존재하지 않는 사용자입니다."));
//
//        Inquiry inq = Inquiry.builder()
//                .user(author)
//                .title(dto.getTitle())
//                .content(dto.getContent())
//                .status(InquiryStatus.WAITING)
//                .build();
//
//        return inquiryRepository.save(inq);
//    }

//    // 관리자 답변 (임시)
//    public void answerInquiry(Long inquiryId, String answerContent, String adminEmail) {
//        if (answerContent == null || answerContent.isBlank()) {
//            throw new Exception400("답변 내용을 입력하세요.");
//        }
//        Inquiry inq = inquiryRepository.findById(inquiryId)
//                .orElseThrow(() -> new Exception404("해당 문의를 찾을 수 없습니다."));
//
//        if (inq.getStatus() != InquiryStatus.WAITING) {
//            throw new Exception400("대기 상태의 문의만 답변할 수 있습니다.");
//        }
//
//        // 개발용: adminEmail 없으면 고정 유저(id=1) 사용 or 아예 admin 세팅 생략
//        User admin = null;
//        if (adminEmail != null) {
//            admin = userJpaRepository.findByEmail(adminEmail)
//                    .orElseThrow(() -> new Exception404("관리자를 찾을 수 없습니다."));
//        } else {
//            admin = userJpaRepository.findById(1L).orElse(null);
//        }
//
//        if (admin != null) inq.setAdmin(admin);
//        inq.setAnswerContent(answerContent);
//        inq.setAnsweredAt(new Timestamp(System.currentTimeMillis()));
//        inq.setStatus(InquiryStatus.ANSWERED);
//    }
}
