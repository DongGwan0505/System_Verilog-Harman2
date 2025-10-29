🧠 System_Verilog-MultiCycle_CPU_AMBA_BUS-25-10-13 ~ 25-10-24

[HARMAN] 세미콘아카데미 – 시스템반도체 설계/검증 엔지니어(2기)
교육 기간: 2025.10.13 ~ 2025.10.24

<프로젝트 개요>

본 저장소는 Multi-Cycle RISC-V CPU 설계 및 AMBA (APB) 버스 적용 과정까지의
학습 및 구현 결과를 포함한 SystemVerilog 기반 프로젝트 파일 모음입니다.

대상 보드: Basys 3

파일 구성: Design Source Files / Simulation Files / XDC Constraints

주요 내용: RV32I 명령어셋 기반 멀티사이클 CPU, APB 버스 연결, GPO / GPI / GPIO / UART 주변장치 통합

🗓️ 일자별 진행 내역
날짜	진행 내용
25-10-13	R-type, I-type 명령어 완성 (RV32I 기본 코어)
25-10-14	S-type (Store) 명령어 추가
25-10-15	L-type (Load), B-type (Branch), U-type (LUI/AUIPC), J-type (JAL) 추가
25-10-16	JL-type (JALR) 추가
25-10-17	Multi Cycle 구조 적용 (제어 FSM 도입)
25-10-21	AMBA BUS Testbench 작성
25-10-22	SystemVerilog Class 기반 검증 환경 구현
25-10-23	GPO Peripheral (APB 연결) 통합
25-10-24	GPI / GPIO Peripheral 추가 및 전체 MCU 완성
⚙️ 주요 기술 구성

CPU Core: RV32I Multi-Cycle Processor (Control Unit + Datapath)

Bus Interface: AMBA APB Master / Decoder / Mux

Memory: ROM (Instruction), RAM (Data)

Peripherals: GPO, GPI, GPIO (입출력 레지스터 기반), UART 추가 확장 가능

Simulation: Vivado Simulator + SystemVerilog Testbench (Class Driver / Monitor / Scoreboard)

Board: Basys 3 (Artix-7 FPGA)

📂 Repository Structure (예시)
System_Verilog-MultiCycle_CPU_AMBA_BUS/
 ├── src/                # Design Source Files (.sv)
 ├── sim/                # Testbench & Class Verification Files
 ├── constraints/        # XDC (Basys3 pin assignments)
 ├── doc/                # Block diagrams / slides / notes
 └── README.md

<결과 요약>

RV32I 명령어셋 전 타입 완성

Multi-Cycle 구조 FSM 구현 (FETCH → DECODE → EXEC → MEM → WB)

AMBA APB 버스 통합 및 GPO/GPI/GPIO 주변장치 연동

Testbench Class 기반 자동 검증 환경 구성

Vivado Simulation PASS / Board 연동 완료
