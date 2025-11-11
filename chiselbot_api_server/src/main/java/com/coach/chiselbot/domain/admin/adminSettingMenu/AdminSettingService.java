package com.coach.chiselbot.domain.admin.adminSettingMenu;

import com.coach.chiselbot._global.errors.adminException.AdminException404;
import com.coach.chiselbot.domain.admin.Admin;
import com.coach.chiselbot.domain.admin.AdminRepository;
import com.coach.chiselbot.domain.admin.dto.AdminRequestDto;
import com.coach.chiselbot.domain.admin.dto.AdminResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AdminSettingService {

    private final PasswordEncoder passwordEncoder;
    private final AdminRepository adminRepository;

    // 등록
    @Transactional
    public AdminResponseDto.FindById createAdmin(AdminRequestDto.adminCreate request){
        Admin newAdmin = new Admin();
        String newPassword = passwordEncoder.encode(request.getPassword());

        newAdmin.setAdminName(request.getAdminName());
        newAdmin.setEmail(request.getEmail());
        newAdmin.setPassword(newPassword); // 암호화 해서 저장

        adminRepository.save(newAdmin);

        return new AdminResponseDto.FindById(newAdmin);
    }

    // email 중복검사
    public boolean checkEmail(String email){
        return adminRepository.existsByEmail(email);
    }


    // 삭제
    @Transactional
    public void deleteAdmin(Long id){
        adminRepository.deleteById(id);
    }

    @Transactional(readOnly = true)
    public Page<AdminResponseDto.FindAll> getAdminList(Pageable pageable) {
        Page<Admin> page = adminRepository.findAll(pageable);
        return page.map(AdminResponseDto.FindAll::new);
    }

    @Transactional(readOnly = true)
    public AdminResponseDto.FindById getDetail(Long id){
        Admin admin = adminRepository.findById(id)
                .orElseThrow(()-> new AdminException404("해당 관리자를 찾을 수 없습니다"));

        return new AdminResponseDto.FindById(admin);
    }

}
