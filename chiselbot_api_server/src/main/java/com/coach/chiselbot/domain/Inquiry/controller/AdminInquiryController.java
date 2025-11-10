package com.coach.chiselbot.domain.Inquiry.controller;

import com.coach.chiselbot.domain.Inquiry.InquiryService;
import com.coach.chiselbot.domain.Inquiry.dto.InquiryRequestDTO;
import com.coach.chiselbot.domain.Inquiry.dto.InquiryResponseDTO;
import com.coach.chiselbot.domain.notice.dto.NoticeRequest;
import com.coach.chiselbot.domain.notice.dto.NoticeResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Controller
@RequestMapping("/admin/inquiries")
@RequiredArgsConstructor
public class AdminInquiryController {

    private final InquiryService inquiryService;

    /**
     * 문의 상세 조회 API
     * GET/admin/inquiries/1
     */
    @GetMapping("/{inquiryId}")
    public String adminInquiryDetail(@PathVariable(name = "inquiryId") Long id,
                                     Model model) {
        InquiryResponseDTO.AdminInquiryDetail inquiryDetail = inquiryService.getAdminInquiryDetail(id);
        model.addAttribute("inquiry",inquiryDetail);
        return "auth/inquiry-detail";
    }

    /**
     * 문의 전체 목록 조회 API
     * GET/admin/inquiries
     */
    @GetMapping
    public String adminInquiries(
            @RequestParam(defaultValue = "0") int page,
            Model model) {
        //Page<InquiryResponseDTO.AdminInquiryList> inquiries = inquiryService.adminInquiryList(page);
        Page<InquiryResponseDTO.AdminInquiryList> inquiryListPage = inquiryService.adminInquiryList(page);
        List<InquiryResponseDTO.AdminInquiryList> inquiryLists = inquiryListPage.getContent();

        int totalPages = inquiryListPage.getTotalPages();
        int currentPage = inquiryListPage.getNumber(); // 0-based
        List<InquiryRequestDTO.PageInfo> pageInfos = IntStream.range(0, totalPages)
                .mapToObj(i -> new InquiryRequestDTO.PageInfo(i + 1, i, i == currentPage))
                .toList();

        /*
        int totalElements = (int) inquiries.getTotalElements();
        int currentPage = inquiries.getNumber();
        int pageSize = inquiries.getSize();
        int totalPages = inquiries.getTotalPages();

        int startNumber = totalElements - (currentPage * pageSize);
        for (int i = 0; i < inquiries.getContent().size(); i++) {
            inquiries.getContent().get(i).setDisplayNumber(startNumber - i);
        }


        // 페이지 번호 목록 생성
        List<Map<String, Object>> pageNumbers = IntStream.range(0, totalPages)
                .mapToObj(i -> Map.<String, Object>ofEntries(
                        Map.entry("index", i),
                        Map.entry("display", i + 1),
                        Map.entry("isCurrent", i == currentPage)
                ))
                .toList();
        */

        // Mustache 에서 사용 할 값 넘겨주는 Model
        model.addAttribute("inquiries", inquiryLists); // 등록되어있는 질문 리스트
        model.addAttribute("currentPage", inquiryListPage.getNumber()+ 1); // 현재 페이지
        model.addAttribute("totalPages", inquiryListPage.getTotalPages()); // 전체 페이지 수
        model.addAttribute("hasNext", inquiryListPage.hasNext()); // 다음 페이지 존재 여부
        model.addAttribute("hasPrevious", inquiryListPage.hasPrevious()); // 이전페이지 존재 여부
        model.addAttribute("nextPage", inquiryListPage.hasNext() ? inquiryListPage.getNumber() + 1 : inquiryListPage.getNumber()); // 다음페이지 번호
        model.addAttribute("prevPage", inquiryListPage.hasPrevious() ? inquiryListPage.getNumber() - 1 : inquiryListPage.getNumber()); // 이전페이지 번호
        model.addAttribute("pageInfos", pageInfos); // 페이지 전체정보
        model.addAttribute("totalElements", inquiryListPage.getTotalElements()); // 전체 질문 수
        model.addAttribute("pageSize", inquiryListPage.getSize()); // 한페이지당 표시 개수 : 10

        return "auth/inquiry-list";
    }


}
