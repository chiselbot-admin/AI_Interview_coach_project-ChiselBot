package com.coach.chiselbot.domain.Inquiry;

import com.coach.chiselbot._global.entity.BaseEntity;
import com.coach.chiselbot.domain.answer.Answer;
import com.coach.chiselbot.domain.user.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Inquiry extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false, length = 200)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private InquiryStatus status = InquiryStatus.WAITING;

    @OneToOne(mappedBy = "inquiry",cascade = CascadeType.ALL, orphanRemoval = true)
    private Answer answer;

}
