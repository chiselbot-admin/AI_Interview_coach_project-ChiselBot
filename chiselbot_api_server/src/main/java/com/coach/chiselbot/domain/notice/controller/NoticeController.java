package com.coach.chiselbot.domain.notice.controller;

import com.coach.chiselbot._global.common.Define;
import com.coach.chiselbot.domain.admin.Admin;
import com.coach.chiselbot.domain.notice.NoticeService;
import com.coach.chiselbot.domain.notice.dto.NoticeRequest;
import com.coach.chiselbot.domain.notice.dto.NoticeResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Slf4j
@Controller
@RequiredArgsConstructor
@RequestMapping("/admin/notice")
public class NoticeController {

    private final NoticeService noticeService;

    @GetMapping
    public String noticeMain(@RequestParam(defaultValue = "0") int page,
                             Model model) {
        Page<NoticeResponse.FindAll> noticePage = noticeService.getNoticeList(page);
        List<NoticeResponse.FindAll> noticeList = noticePage.getContent();

        int totalPages = noticePage.getTotalPages();
        int currentPage = noticePage.getNumber(); // 0-based
        List<NoticeRequest.PageInfo> pageInfos = IntStream.range(0, totalPages)
                .mapToObj(i -> new NoticeRequest.PageInfo(i + 1, i, i == currentPage))
                .collect(Collectors.toList());

        // Mustache 에서 사용 할 값 넘겨주는 Model
        model.addAttribute("notices", noticeList); // 등록되어있는 질문 리스트
        model.addAttribute("currentPage", noticePage.getNumber()+ 1); // 현재 페이지
        model.addAttribute("totalPages", noticePage.getTotalPages()); // 전체 페이지 수
        model.addAttribute("hasNext", noticePage.hasNext()); // 다음 페이지 존재 여부
        model.addAttribute("hasPrevious", noticePage.hasPrevious()); // 이전페이지 존재 여부
        model.addAttribute("nextPage", noticePage.hasNext() ? noticePage.getNumber() + 1 : noticePage.getNumber()); // 다음페이지 번호
        model.addAttribute("prevPage", noticePage.hasPrevious() ? noticePage.getNumber() - 1 : noticePage.getNumber()); // 이전페이지 번호
        model.addAttribute("pageInfos", pageInfos); // 페이지 전체정보
        model.addAttribute("totalElements", noticePage.getTotalElements()); // 전체 질문 수
        model.addAttribute("pageSize", noticePage.getSize()); // 한페이지당 표시 개수 : 10

        return "notice/notice_list";
    }

    @GetMapping("/{noticeId}")
    public String noticeDetail(@PathVariable(name = "noticeId") Long noticeId,
                                 Model model){

        NoticeResponse.FindById notice = noticeService.getNoticeDetail(noticeId);

        model.addAttribute("notice", notice);
        model.addAttribute("prevNotice", noticeService.findPrevious(noticeId));
        model.addAttribute("nextNotice", noticeService.findNext(noticeId));
        return "notice/notice_detail";

    }

    @DeleteMapping("/{noticeId}")
    public ResponseEntity<Void> deleteNotice(@PathVariable Long noticeId,
                                             @SessionAttribute(value = Define.SESSION_USER) Admin admin) {
        noticeService.deleteNotice(noticeId, admin);
        return ResponseEntity.noContent().build(); // 204 응답
    }

    /** 공지사항 등록화면 이동 **/
    @GetMapping("/form")
    public String noticeForm() {
        return "notice/notice_form";
    }

    /** 공지사항 등록화면 이동 **/
    @GetMapping("/update/{noticeId}")
    public String noticeUpdateForm(@PathVariable(name = "noticeId") Long noticeId,
                                   Model model) {

        NoticeResponse.FindById notice = noticeService.getNoticeDetail(noticeId);

        model.addAttribute("notice", notice);

        return "notice/notice_update";
    }

    /** 공지사항 등록 **/
    @PostMapping
    @ResponseBody
    public ResponseEntity<Long> createNotice(@RequestBody NoticeRequest.CreateNotice reqDTO,
                                             @SessionAttribute(value = Define.SESSION_USER) Admin admin) {

        noticeService.createNotice(reqDTO, admin);
        return ResponseEntity.noContent().build();
    }


    /** 공지사항 수정 */
    @PutMapping("/{id}")
    @ResponseBody
    public ResponseEntity<Void> updateNotice(@PathVariable Long id,
                                             @RequestBody NoticeRequest.UpdateNotice reqDTO,
                                             @SessionAttribute(value = Define.SESSION_USER) Admin admin) {
        noticeService.updateNotice(id, reqDTO, admin);
        return ResponseEntity.noContent().build();
    }
}
