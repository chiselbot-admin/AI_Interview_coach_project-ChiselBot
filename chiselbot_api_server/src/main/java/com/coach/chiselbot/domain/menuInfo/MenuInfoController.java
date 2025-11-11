package com.coach.chiselbot.domain.menuInfo;

import com.coach.chiselbot._global.common.Define;
import com.coach.chiselbot._global.common.PageLink;
import com.coach.chiselbot._global.dto.CommonResponseDto;
import com.coach.chiselbot.domain.menuInfo.dto.MenuInfoRequest;
import com.coach.chiselbot.domain.menuInfo.dto.MenuInfoResponse;
import com.coach.chiselbot.domain.notice.dto.NoticeResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Controller
@RequestMapping("/admin/menus")
@RequiredArgsConstructor
public class MenuInfoController {
    private final MenuInfoService menuInfoService;

    @GetMapping
    public String menuInfoPage(@RequestParam(defaultValue = "0") int page,
                                Model model) {

        Page<MenuInfoResponse.FindAll> menuInfoPage = menuInfoService.getAllMenus(page);
        List<MenuInfoResponse.FindAll> menuInfos = menuInfoPage.getContent();

        int totalPages = menuInfoPage.getTotalPages();
        int currentPage = menuInfoPage.getNumber(); // 0-based
        List<PageLink> pageInfos = IntStream.range(0, totalPages)
                .mapToObj(i -> new PageLink(i + 1, i, i == currentPage))
                .collect(Collectors.toList());

        // Mustache 에서 사용 할 값 넘겨주는 Model
        model.addAttribute("menuInfo", menuInfos); // 등록되어있는 질문 리스트
        model.addAttribute("currentPage", menuInfoPage.getNumber()+ 1); // 현재 페이지
        model.addAttribute("totalPages", menuInfoPage.getTotalPages()); // 전체 페이지 수
        model.addAttribute("hasNext", menuInfoPage.hasNext()); // 다음 페이지 존재 여부
        model.addAttribute("hasPrevious", menuInfoPage.hasPrevious()); // 이전페이지 존재 여부
        model.addAttribute("nextPage", menuInfoPage.hasNext() ? menuInfoPage.getNumber() + 1 : menuInfoPage.getNumber()); // 다음페이지 번호
        model.addAttribute("prevPage", menuInfoPage.hasPrevious() ? menuInfoPage.getNumber() - 1 : menuInfoPage.getNumber()); // 이전페이지 번호
        model.addAttribute("pageInfos", pageInfos); // 페이지 전체정보
        model.addAttribute("totalElements", menuInfoPage.getTotalElements()); // 전체 질문 수
        model.addAttribute("pageSize", menuInfoPage.getSize()); // 한페이지당 표시 개수 : 10

        //model.addAttribute("menuInfo",  menuInfos);
        return "menuInfo/menuInfo_list";
    }

    // 중복검사
    @GetMapping("/checkOrder")
    @ResponseBody
    public ResponseEntity<?> checkOrder(@RequestParam(name = "menuOrder") Integer menuOrder){
        boolean exists = menuInfoService.existsByMenuOrder(menuOrder);
        return ResponseEntity.ok(CommonResponseDto.success(exists));
    }

//    @PostMapping("/create")
//    @ResponseBody
//    public ResponseEntity<?> createMenu(MenuInfoRequest.CreateMenu request){
//
//        MenuInfoResponse.FindById newMenu = menuInfoService.createMenu(request);
//
//        return ResponseEntity.ok(CommonResponseDto.success(newMenu, Define.SUCCESS));
//    }

    @PostMapping("/create")
    public String createMenu(MenuInfoRequest.CreateMenu request, RedirectAttributes rttr){
        menuInfoService.createMenu(request);
        rttr.addFlashAttribute("message", Define.SUCCESS);
        return "redirect:/admin/menus";
    }

//    @PostMapping("/update/{id}")
//    public ResponseEntity<?> updateMenu(@PathVariable(name = "id") Long menuId ,
//                                        MenuInfoRequest.UpdateMenu request){
//
//        MenuInfoResponse.FindById updateMenu = menuInfoService.updateMenu(menuId, request);
//
//        return ResponseEntity.ok(CommonResponseDto.success(updateMenu, Define.SUCCESS));
//    }

    @PostMapping("/update/{id}")
    public String updateMenu(@PathVariable(name = "id") Long menuId ,
                             MenuInfoRequest.UpdateMenu request,
                             RedirectAttributes rttr){

        menuInfoService.updateMenu(menuId, request);
        rttr.addFlashAttribute("message", Define.SUCCESS);

        return "redirect:/admin/menus";
    }

    @GetMapping("/delete/{id}")
    public String deleteMenu(@PathVariable Long id, RedirectAttributes rttr) {
        menuInfoService.deleteMenu(id);
        rttr.addFlashAttribute("message", Define.SUCCESS);
        return "redirect:/admin/menus";
    }

    @GetMapping("/create")
    public String createMenuForm(){
        return "menuInfo/menuInfo_form";
    }

    @GetMapping("/update/{id}")
    public String detailMenu(@PathVariable(name = "id") Long id, Model model){
        MenuInfoResponse.FindById menu = menuInfoService.findById(id);
        model.addAttribute("menu", menu);

        return "menuInfo/menuInfo_update";
    }
}
