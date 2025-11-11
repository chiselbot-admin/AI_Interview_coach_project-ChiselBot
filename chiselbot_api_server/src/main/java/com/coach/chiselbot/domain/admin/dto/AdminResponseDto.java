package com.coach.chiselbot.domain.admin.dto;

import com.coach.chiselbot.domain.admin.Admin;
import lombok.Getter;
import lombok.Setter;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class AdminResponseDto
{

    @Getter
    @Setter
    public static class FindById{
        private Long id;
        private String adminName;
        private String email;
        private String password;
        private String createdAt;
        private String modifiedAt;

        public FindById(Admin admin){
            this.id = admin.getId();
            this.adminName =  admin.getAdminName();
            this.email = admin.getEmail();
            this.password = admin.getPassword();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
            // view에 띄우기 위해 포맷(yyyy-MM-dd HH:mm)
            this.createdAt = admin.getCreatedAt() != null ? admin.getCreatedAt().format(formatter) : null;
            this.modifiedAt = admin.getModifiedAt() != null ? admin.getModifiedAt().format(formatter) : null;
        }
    }

    @Getter
    @Setter
    public static class FindAll{
        private Long id;
        private String adminName;
        private String email;
        private String password;
        private String createdAt;
        private String modifiedAt;

        public FindAll(Admin admin){
            this.id = admin.getId();
            this.adminName =  admin.getAdminName();
            this.email = admin.getEmail();
            this.password = admin.getPassword();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
            // view에 띄우기 위해 포맷(yyyy-MM-dd HH:mm)
            this.createdAt = admin.getCreatedAt() != null ? admin.getCreatedAt().format(formatter) : null;
            this.modifiedAt = admin.getModifiedAt() != null ? admin.getModifiedAt().format(formatter) : null;
        }

        public static List<AdminResponseDto.FindAll> from(List<Admin> admins){
            List<AdminResponseDto.FindAll> dtoList = new ArrayList<>();
            for(Admin admin : admins){
                dtoList.add(new AdminResponseDto.FindAll(admin));
            }
            return dtoList;
        }
    }
}
