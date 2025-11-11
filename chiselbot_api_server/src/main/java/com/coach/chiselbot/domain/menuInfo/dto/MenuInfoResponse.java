package com.coach.chiselbot.domain.menuInfo.dto;

import com.coach.chiselbot.domain.menuInfo.MenuInfo;
import com.coach.chiselbot.domain.notice.Notice;
import com.coach.chiselbot.domain.notice.dto.NoticeResponse;
import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

public class MenuInfoResponse {

    @Getter
    @Setter
    public static class FindById{
        private Long id;
        private String menuName;
        private String menuCode;
        private MenuInfo parent;
        private Integer menuOrder;
        private String urlPath;
        private Boolean visible;
        private String description;

        public FindById(MenuInfo menuInfo){
            this.id = menuInfo.getId();
            this.menuName = menuInfo.getMenuName();
            this.menuCode = menuInfo.getMenuCode();
            this.parent = menuInfo.getParent();
            this.menuOrder = menuInfo.getMenuOrder();
            this.visible = menuInfo.getVisible();
            this.urlPath = menuInfo.getUrlPath();
            this.description = menuInfo.getDescription();
        }
    }

    @Setter
    @Getter
    public static class FindAll{
        private Long id;
        private String menuName;
        private String menuCode;
        private MenuInfo parent;
        private Integer menuOrder;
        private String urlPath;
        private Boolean visible;
        private String description;

        private boolean isMenuManagement; // 메뉴관리 메뉴인지 판단

        public FindAll(MenuInfo menuInfo){
            this.id = menuInfo.getId();
            this.menuName = menuInfo.getMenuName();
            this.menuCode = menuInfo.getMenuCode();
            this.parent = menuInfo.getParent();
            this.menuOrder = menuInfo.getMenuOrder();
            this.visible = menuInfo.getVisible();
            this.urlPath = menuInfo.getUrlPath();
            this.description = menuInfo.getDescription();
            this.isMenuManagement = "메뉴관리".equals(menuInfo.getMenuName()) ||
                    "MENU_MANAGEMENT".equals(menuInfo.getMenuCode());
        }

        public static MenuInfoResponse.FindAll from(MenuInfo menuInfo){return new MenuInfoResponse.FindAll(menuInfo);}

        public static List<MenuInfoResponse.FindAll> from(List<MenuInfo> menuInfos){
            List<MenuInfoResponse.FindAll> dtoList = new ArrayList<>();
            for(MenuInfo menuInfo : menuInfos){
                dtoList.add(new MenuInfoResponse.FindAll(menuInfo));
            }
            return dtoList;
        }
    }
}
