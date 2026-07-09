from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output" / "pdf"
OUT.mkdir(parents=True, exist_ok=True)
PDF_PATH = OUT / "MoonWatermarkKit_项目申报书.pdf"


def register_font():
    for font in [Path("C:/Windows/Fonts/msyh.ttc"), Path("C:/Windows/Fonts/simhei.ttf"), Path("C:/Windows/Fonts/simsun.ttc")]:
        if font.exists():
            pdfmetrics.registerFont(TTFont("CN", str(font)))
            return "CN"
    return "Helvetica"


FONT = register_font()
styles = getSampleStyleSheet()
title = ParagraphStyle("TitleCN", parent=styles["Title"], fontName=FONT, fontSize=18, leading=24, textColor=colors.HexColor("#18324A"), alignment=1, spaceAfter=10)
heading = ParagraphStyle("HeadingCN", parent=styles["Heading2"], fontName=FONT, fontSize=12, leading=16, textColor=colors.HexColor("#245B83"), spaceBefore=6, spaceAfter=4)
body = ParagraphStyle("BodyCN", parent=styles["BodyText"], fontName=FONT, fontSize=9.2, leading=13.5, spaceAfter=4)
small = ParagraphStyle("SmallCN", parent=body, fontSize=8.4, leading=12)


def p(text, style=body):
    return Paragraph(text.replace("\n", "<br/>"), style)


def table(rows):
    t = Table([[p(k, small), p(v, small)] for k, v in rows], colWidths=[32 * mm, 132 * mm])
    t.setStyle(TableStyle([
        ("FONTNAME", (0, 0), (-1, -1), FONT),
        ("GRID", (0, 0), (-1, -1), 0.25, colors.HexColor("#B7C6D1")),
        ("BACKGROUND", (0, 0), (0, -1), colors.HexColor("#EEF5F8")),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("LEFTPADDING", (0, 0), (-1, -1), 6),
        ("RIGHTPADDING", (0, 0), (-1, -1), 6),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
    ]))
    return t


story = [p("MoonWatermarkKit 项目申报书", title)]
story.append(table([
    ("项目名称", "MoonWatermarkKit：面向 MoonBit 的事件时间水位线、迟到事件与窗口归属基础库"),
    ("参赛者", "待填写"),
    ("联系方式", "待填写"),
    ("GitHub 仓库", "待填写"),
    ("GitLink 仓库", "待填写"),
    ("项目方向", "MoonBit 数据工程基础库 / 流式事件时间处理"),
    ("是否移植项目", "否，原创 MoonBit 基础库"),
]))
story.append(Spacer(1, 6))

sections = [
    ("一、项目简介", "MoonWatermarkKit 面向 MoonBit 生态提供事件时间水位线、迟到事件判定、窗口归属、窗口聚合和流审计能力。项目适用于日志流、指标流、点击流、IoT 传感器事件、消息队列消费和离线回放等场景，帮助应用在乱序到达的数据中保持窗口计算语义清晰。"),
    ("二、核心价值", "MoonBit 生态已有 async I/O、DataFrame、压缩和文件处理等项目，但缺少专门的 event-time watermark 基础库。MoonWatermarkKit 不做消息队列或分布式流引擎，而是提供可嵌入的水位线与窗口决策核心。"),
    ("三、已实现功能", "1. StreamEvent、WatermarkPolicy、WatermarkState、TimeWindow、WindowSpec 等公开类型。<br/>2. 支持最大事件时间推进水位线、乱序容忍、允许迟到和 idle 检测。<br/>3. 支持 on_time、late、too_late 三类事件状态。<br/>4. 支持 tumbling/sliding 窗口归属、窗口聚合、审计统计、JSON 导出和 CLI 演示。<br/>5. 提供 10 个回归测试、跨平台 CI 和 README 文档。"),
    ("四、创新点", "项目把流式计算中容易散落在业务里的水位线和迟到事件逻辑抽成稳定 API。上层系统可以只关注事件输入和窗口结果，而把乱序、迟到、丢弃和审计交给 MoonWatermarkKit。"),
    ("五、技术路线", "核心实现保持零依赖和后端中立，不依赖消息系统、数据库或平台 IO。当前版本提供纯函数式状态推进和窗口归属；后续可接入 async 流、DataFrame、指标库或日志系统。"),
    ("六、与社区项目差异", "与 DataFrame 类项目相比，本项目关注流式事件时间语义；与 async I/O 类项目相比，本项目不负责传输，而负责事件到达后的水位线、迟到与窗口决策。"),
    ("七、阶段计划", "后续补充 session window、trigger 策略、early/late firing、watermark merge、分区水位线、窗口状态压缩和真实日志/IoT 示例。"),
    ("八、提交说明", "项目以公开仓库方式组织，提交记录覆盖基础架构、核心类型、水位线、窗口、聚合、审计、测试、文档和申报书，便于评审追踪开发过程。"),
]
for name, text in sections:
    story.append(p(name, heading))
    story.append(p(text))

doc = SimpleDocTemplate(str(PDF_PATH), pagesize=A4, rightMargin=18 * mm, leftMargin=18 * mm, topMargin=16 * mm, bottomMargin=16 * mm)
doc.build(story)
print(PDF_PATH)

