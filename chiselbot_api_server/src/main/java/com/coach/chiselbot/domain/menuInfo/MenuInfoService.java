package com.coach.chiselbot.domain.menuInfo;

import com.coach.chiselbot._global.errors.adminException.AdminException404;
import com.coach.chiselbot.domain.menuInfo.dto.MenuInfoRequest;
import com.coach.chiselbot.domain.menuInfo.dto.MenuInfoResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MenuInfoService {

    private final MenuInfoRepository menuInfoRepository;

    /**
     * 전체 메뉴 목록 조회 (부모-자식 포함)
     */
    public List<MenuInfo> getVisibleTrueAllMenus() {
        return menuInfoRepository.findAllByVisibleTrueOrderByMenuOrderAsc();
    }

    public List<MenuInfoResponse.FindAll> getAllMenus() {
        List<MenuInfo> menus = menuInfoRepository.findAll(Sort.by(Sort.Direction.ASC, "menuOrder"));
        return MenuInfoResponse.FindAll.from(menus);
    }

    /**
     * 루트 메뉴만 조회 (parent_id가 null)
     */
    public List<MenuInfo> getRootMenus() {
        return menuInfoRepository.findByParentIsNullOrderByMenuOrderAsc();
    }

    public boolean existsByMenuOrder(Integer menuOrder){
        return menuInfoRepository.existsByMenuOrder(menuOrder);
    }

    @Transactional
    public MenuInfoResponse.FindById createMenu(MenuInfoRequest.CreateMenu request){

        Integer order = request.getMenuOrder();

        // order가 중복될 경우 이후 모든 메뉴 순서 +1
        // findByMenuOrderGreaterThanEqual(order): order 보다 크거나 같은 수 조회
        List<MenuInfo> conflictMenus = menuInfoRepository.findByMenuOrderGreaterThanEqual(order);
        for (MenuInfo menu : conflictMenus) {
            menu.setMenuOrder(menu.getMenuOrder() + 1);
        }

        MenuInfo newMenuInfo = MenuInfo.builder()
                .menuName(request.getMenuName())
                .menuCode(request.getMenuCode())
                .parent(request.getParent())
                .menuOrder(order)
                .urlPath(request.getUrlPath())
                .visible(request.getVisible())
                .description(request.getDescription())
                .build();

        menuInfoRepository.save(newMenuInfo);

        return new MenuInfoResponse.FindById(newMenuInfo);
    }

    @Transactional
    public MenuInfoResponse.FindById updateMenu(Long menuId ,MenuInfoRequest.UpdateMenu request){
        MenuInfo updateMenuInfo = menuInfoRepository.findById(menuId)
                .orElseThrow(() -> new AdminException404("해당 메뉴를 찾을 수 없습니다"));

        Integer oldOrder = updateMenuInfo.getMenuOrder();
        Integer newOrder = request.getMenuOrder();

        // 현재 order와 다르고, 새로운 order가 이미 존재한다면 이후 순서 전부 +1
        if (!oldOrder.equals(newOrder)) {
            if (newOrder > oldOrder) {
                // 아래로 이동하는 경우 → 사이 구간의 메뉴들을 -1
                List<MenuInfo> betweenMenus = menuInfoRepository.findByMenuOrderBetween(oldOrder + 1, newOrder);
                for (MenuInfo menu : betweenMenus) {
                    menu.setMenuOrder(menu.getMenuOrder() - 1);
                }
            } else {
                // 위로 이동하는 경우 → 사이 구간의 메뉴들을 +1
                List<MenuInfo> betweenMenus = menuInfoRepository.findByMenuOrderBetween(newOrder, oldOrder - 1);
                for (MenuInfo menu : betweenMenus) {
                    menu.setMenuOrder(menu.getMenuOrder() + 1);
                }
            }
        }

        updateMenuInfo.setMenuOrder(newOrder);
        updateMenuInfo.setMenuName(request.getMenuName());
        updateMenuInfo.setMenuCode(request.getMenuCode());
        updateMenuInfo.setParent(request.getParent());
        updateMenuInfo.setUrlPath(request.getUrlPath());
        updateMenuInfo.setVisible(request.getVisible());
        updateMenuInfo.setDescription(request.getDescription());

        return new MenuInfoResponse.FindById(updateMenuInfo);
    }

    @Transactional
    public void deleteMenu(Long menuId){
        MenuInfo menuInfo= menuInfoRepository.findById(menuId)
                .orElseThrow(() -> new AdminException404("해당 메뉴를 찾을 수 없습니다"));

        if (menuInfoRepository.existsByMenuOrder(menuInfo.getMenuOrder())) {
            List<MenuInfo> conflictMenus = menuInfoRepository.findByMenuOrderGreaterThan(menuInfo.getMenuOrder());
            for (MenuInfo menu : conflictMenus) {
                menu.setMenuOrder(menu.getMenuOrder() - 1);
            }
        }

        menuInfoRepository.deleteById(menuId);
    }

    public MenuInfoResponse.FindById findById(Long id){
        MenuInfo menuInfo = menuInfoRepository.findById(id)
                .orElseThrow(() -> new AdminException404("해당 메뉴를 찾을 수 없습니다"));

        return new MenuInfoResponse.FindById(menuInfo);
    }


}
