package com.coach.chiselbot._global.common;

import lombok.*;

@Data
@AllArgsConstructor
public class PageLink {

    private int number;      // 1-based 표시용
    private int index;       // 0-based 실제 쿼리 파라미터용
    private boolean current; // 현재 페이지 여부
}
