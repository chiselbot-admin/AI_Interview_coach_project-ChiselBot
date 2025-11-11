package com.coach.chiselbot.domain.notice;

import com.coach.chiselbot._global.common.Define;
import com.coach.chiselbot._global.errors.adminException.AdminException404;
import com.coach.chiselbot.domain.admin.Admin;
import com.coach.chiselbot.domain.admin.AdminRepository;
import com.coach.chiselbot.domain.notice.dto.NoticeRequest;
import com.coach.chiselbot.domain.notice.dto.NoticeResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class NoticeService {

    private final NoticeRepository noticeRepository;
    private final AdminRepository adminRepository;


    public Page<NoticeResponse.FindAll> getNoticeList(int page){
        int pageSize = 10;
        Pageable pageable = PageRequest.of(page, pageSize, Sort.by("noticeId").descending());

        return noticeRepository.findAll(pageable).map(notice -> NoticeResponse.FindAll.from(notice));
    }

    public List<NoticeResponse.FindAll> getNoticeList(){

        List<Notice> noticeList = noticeRepository.findByIsVisibleTrueOrderByNoticeIdDesc();
        NoticeResponse.FindAll.from(noticeList);

        return NoticeResponse.FindAll.from(noticeList);
    }

    public NoticeResponse.FindById getNoticeDetail(Long noticeId){
        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(()-> new AdminException404(Define.NOTICE_NOT_FOUND));


        return new NoticeResponse.FindById(notice);
    }

    @Transactional
    public NoticeResponse.FindById getNoticeDetailWithViewCount(Long noticeId){
        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(()-> new AdminException404(Define.NOTICE_NOT_FOUND));

        notice.increaseViewCount();

        return new NoticeResponse.FindById(notice);
    }

    public Notice findPrevious(Long id) {
        Optional<Notice> prev = noticeRepository.findFirstByNoticeIdLessThanOrderByNoticeIdDesc(id);
        return prev.orElse(null);
    }

    public Notice findNext(Long id) {
        Optional<Notice> next = noticeRepository.findFirstByNoticeIdGreaterThanOrderByNoticeIdAsc(id);
        return next.orElse(null);
    }

    @Transactional
    public void deleteNotice(Long noticeId, Admin admin) {

        Admin searchAdmin = adminRepository.findById(admin.getId()).orElseThrow(() -> new AdminException404(Define.ADMIN_NOT_FOUND));

        Notice notice = noticeRepository.findById(noticeId)
                .orElseThrow(() -> new AdminException404(Define.NOTICE_NOT_FOUND));

        noticeRepository.delete(notice);
    }

    @Transactional
    public void updateNotice(Long id, NoticeRequest.UpdateNotice reqDTO, Admin admin) {

        Admin searchAdmin = adminRepository.findById(admin.getId()).orElseThrow(() -> new AdminException404(Define.ADMIN_NOT_FOUND));

        Notice notice = noticeRepository.findById(id)
                .orElseThrow(() -> new AdminException404(Define.NOTICE_NOT_FOUND));

        notice.setTitle(reqDTO.getTitle());
        notice.setContent(reqDTO.getNoticeContent());
        notice.setIsVisible(reqDTO.isVisible());
        notice.setAdmin(searchAdmin);
    }

    @Transactional
    public void createNotice(NoticeRequest.CreateNotice reqDTO, Admin admin) {


        Admin searchAdmin = adminRepository.findById(admin.getId()).orElseThrow(() -> new AdminException404(Define.ADMIN_NOT_FOUND));

        Notice notice = Notice.builder()
                .title(reqDTO.getTitle())
                .content(reqDTO.getNoticeContent())
                .isVisible(reqDTO.isVisible())
                .viewCount(0)
                .admin(searchAdmin)
                .build();

        noticeRepository.save(notice);
    }
}
