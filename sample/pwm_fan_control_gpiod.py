#!/usr/bin/env python3

import gpiod
import time
import subprocess
import threading

# Pelase change to gpiochip4 if you are it on ubuntu 24.04 server
#chipname = "gpiochip4"
chipname = "gpiochip0"
servo_line_offset = 13  # 替代使用 BCM 13 的 GPIO 引脚

# 打开 GPIO 芯片并请求 PWM 引脚
chip = gpiod.Chip(chipname)
servo_line = chip.get_line(servo_line_offset)
servo_line.request(consumer="fan_controller", type=gpiod.LINE_REQ_DIR_OUT)

# Simulate PWM function
class SoftwarePWM:
    def __init__(self, line, frequency):
        self.line = line
        self.frequency = frequency
        self.duty_cycle = 0  # 初始占空比为 0
        self.period = 1 / frequency
        self.running = False

    def change_duty_cycle(self, duty_cycle):
        self.duty_cycle = max(0, min(100, duty_cycle))  # 确保占空比在 0 到 100 之间

    def start(self):
        self.running = True
        while self.running:
            if self.duty_cycle > 0:
                high_time = (self.duty_cycle / 100) * self.period
                low_time = self.period - high_time
                self.line.set_value(1)
                time.sleep(high_time)
                self.line.set_value(0)
                time.sleep(low_time)
            else:
                self.line.set_value(0)
                time.sleep(self.period)  # 如果 duty_cycle 为 0，则保持低电平

    def stop(self):
        self.running = False
        self.line.set_value(0)

# 获取 CPU 温度
def get_temp():
    output = subprocess.run(['vcgencmd', 'measure_temp'], capture_output=True)
    temp_str = output.stdout.decode()
    try:
        return float(temp_str.split('=')[1].split('\'')[0])
    except (IndexError, ValueError):
        raise RuntimeError('DO NOT GET temperature')

# 创建 PWM 控制对象
fan_pwm = SoftwarePWM(servo_line, frequency=200)

# 启动 PWM 信号模拟的线程
pwm_thread = threading.Thread(target=fan_pwm.start)
pwm_thread.daemon = True  # 确保在主线程退出时也会退出

try:
    pwm_thread.start()  # 启动 PWM 控制线程

    # 主循环，根据温度调节占空比
    while True:
        temp = get_temp()  # 获取当前 CPU 温度
        if temp > 70:
            fan_pwm.change_duty_cycle(100)  # 100% 占空比
        elif temp > 60:
            fan_pwm.change_duty_cycle(85)
        elif temp > 50:
            fan_pwm.change_duty_cycle(60)
        elif temp > 40:
            fan_pwm.change_duty_cycle(50)
        elif temp > 32:
            fan_pwm.change_duty_cycle(45)
        elif temp > 25:
            fan_pwm.change_duty_cycle(40)
        else:
            fan_pwm.change_duty_cycle(0)  # 关闭风扇
        time.sleep(5)  # 每隔 5 秒调整一次占空比
except KeyboardInterrupt:
    print("QUIT...")
finally:
    fan_pwm.stop()  # 停止 PWM
    pwm_thread.join()  # 等待 PWM 线程结束
    chip.close()
