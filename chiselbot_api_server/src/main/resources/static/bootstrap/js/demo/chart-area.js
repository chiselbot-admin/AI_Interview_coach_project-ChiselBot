Chart.defaults.global.defaultFontFamily =
  'Nunito', '-apple-system,system-ui,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif';
Chart.defaults.global.defaultFontColor = '#858796';

function number_format(number, decimals, dec_point, thousands_sep) {
  number = (number + '').replace(',', '').replace(' ', '');
  var n = !isFinite(+number) ? 0 : +number,
    prec = !isFinite(+decimals) ? 0 : Math.abs(decimals),
    sep = (typeof thousands_sep === 'undefined') ? ',' : thousands_sep,
    dec = (typeof dec_point === 'undefined') ? '.' : dec_point,
    s = '',
    toFixedFix = function (n, prec) {
      var k = Math.pow(10, prec);
      return '' + Math.round(n * k) / k;
    };
  s = (prec ? toFixedFix(n, prec) : '' + Math.round(n)).split('.');
  if (s[0].length > 3) s[0] = s[0].replace(/\B(?=(?:\d{3})+(?!\d))/g, sep);
  if ((s[1] || '').length < prec) {
    s[1] = s[1] || '';
    s[1] += new Array(prec - s[1].length + 1).join('0');
  }
  return s.join(dec);
}

// 차트 렌더링 함수
const ctx = document.getElementById('myAreaChart').getContext('2d');
let chart;
function renderInquiryChart(year) {
  fetch(`/admin/inquiry-stats/year?year=${year}`)
    .then(res => res.json())
    .then(data => {
        const labels = ["1월","2월","3월","4월","5월","6월","7월","8월","9월","10월","11월","12월"];

        const dataMap = {};
        data.forEach(item => dataMap[parseInt(item.month)] = item.count);

        const counts = labels.map((_, i) => dataMap[i + 1] || 0);

      chart = new Chart(ctx, {
         type: 'bar', // 기본 타입을 막대로
          data: {
            labels: labels,
            datasets: [
              {
                type: 'bar',
                label: `${year}년 월별 문의 수`,
                data: counts,
                backgroundColor: [
                  'rgba(255, 159, 64, 0.7)',  // 1월
                  'rgba(255, 159, 64, 0.7)',  // 2월
                  'rgba(255, 159, 64, 0.7)',  // 3월
                  'rgba(255, 205, 86, 0.7)',  // 4월
                  'rgba(255, 205, 86, 0.7)',  // 5월
                  'rgba(255, 205, 86, 0.7)',  // 6월
                  'rgba(255, 99, 132, 0.7)',  // 7월
                  'rgba(255, 99, 132, 0.7)',  // 8월
                  'rgba(255, 99, 132, 0.7)',  // 9월
                  'rgba(153, 102, 255, 0.7)', // 10월
                  'rgba(153, 102, 255, 0.7)', // 11월
                  'rgba(153, 102, 255, 0.7)', // 12월
                ],
                borderColor: 'rgba(255, 255, 255, 1)',
                borderWidth: 1,
              }
            ],
          },
        options: {
          maintainAspectRatio: false,
          layout: {
            padding: { left: 10, right: 25, top: 25, bottom: 0 }
          },
          scales: {
            xAxes: [{
              gridLines: { display: false, drawBorder: false },
              ticks: { maxTicksLimit: 12 }
            }],
            yAxes: [{
              ticks: {
                  beginAtZero: true,
                  suggestedMin: 0,   // 기본 최소값
                  suggestedMax: 60,  // 기본 최대값
                  stepSize: 20,      // 눈금 간격
                  padding: 10,
                  callback: function (value) {
                    return number_format(value) + '건';
                  }
                },
              gridLines: {
                color: "rgb(234, 236, 244)",
                zeroLineColor: "rgb(234, 236, 244)",
                drawBorder: false,
                borderDash: [2],
                zeroLineBorderDash: [2]
              }
            }],
          },
          legend: { display: false },
          tooltips: {
            backgroundColor: "rgb(255,255,255)",
            bodyFontColor: "#858796",
            titleMarginBottom: 10,
            titleFontColor: '#6e707e',
            titleFontSize: 14,
            borderColor: '#dddfeb',
            borderWidth: 1,
            xPadding: 15,
            yPadding: 15,
            displayColors: false,
            intersect: false,
            mode: 'index',
            caretPadding: 10,
            callbacks: {
              label: function (tooltipItem, chart) {
                var datasetLabel = chart.datasets[tooltipItem.datasetIndex].label || '';
                return datasetLabel + ': ' + number_format(tooltipItem.yLabel) + '건';
              }
            }
          }
        }
      });
    })
    .catch(err => console.error('차트 데이터 로드 실패:', err)); // 에러 핸들링
}


// 연도 선택 이벤트
document.addEventListener('DOMContentLoaded', () => {
  const yearSelect = document.getElementById('yearSelect');
  if (!yearSelect) return;

  yearSelect.addEventListener('change', e => renderInquiryChart(e.target.value));
  renderInquiryChart(yearSelect.value); // 초기 로드
});

Chart.plugins.register({
  afterDraw: function (chart) {
    if (!chart.data.datasets.length) return;

    const data = chart.data.datasets[0].data;
    const isAllZero = data.every(v => v === 0);

    if (isAllZero) {
      const ctx = chart.chart.ctx;
      const width = chart.chart.width;
      const height = chart.chart.height;
      chart.clear();

      ctx.save();
      ctx.textAlign = 'center';
      ctx.textBaseline = 'middle';
      ctx.font = "16px 'Noto Sans KR'";
      ctx.fillStyle = '#999';
      ctx.fillText('데이터 없음', width / 2, height / 2);
      ctx.restore();
    }
  }
});