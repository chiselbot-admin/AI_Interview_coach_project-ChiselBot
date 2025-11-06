package com.coach.chiselbot.domain.user;

import com.coach.chiselbot._global.entity.BaseEntity;
import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "user_table")
@Builder
public class User extends BaseEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column
    private String name;

    @Column
    private String email;

    @Column
    private String password;

    @Column
    private String profileImage;

    @Column(unique = true)
    private String kakaoId; // 카카오 고유 ID

    @Enumerated(EnumType.STRING)
    private Provider provider;

    /*
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role;

    @OneToMany(mappedBy = "reporter")
    private List<Issue> issues = new ArrayList<>();
     */

}