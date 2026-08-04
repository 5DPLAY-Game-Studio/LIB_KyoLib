/*
 * Copyright (C) 2021-2026, 5DPLAY Game Studio
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package net.play5d.kyo.air.utils {
import flash.desktop.NativeProcess;
import flash.desktop.NativeProcessStartupInfo;
import flash.events.NativeProcessExitEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;
import flash.filesystem.File;
import flash.utils.Timer;
import flash.utils.setTimeout;

/**
 * AIR NativeProcess / CMD 辅助。
 *
 * <p>位于 <code>net.play5d.kyo.air</code> 下，表示<strong>仅 AIR</strong>可用。
 * 配置需声明：<code>&lt;supportedProfiles&gt;extendedDesktop desktop&lt;/supportedProfiles&gt;</code>。</p>
 *
 * @see #createProcess()
 * @see #callCMD()
 */
public class ProcessUtils {
    /**
     * 启动程序。
     * @param path 程序路径。
     * @param arguments 启动参数 <code>Array</code> 或 <code>String</code>。
     * @return 已启动的 <code>NativeProcess</code>；不支持或文件不存在时为 <code>null</code>。
     * @example
     * <listing version="3.0">
     * var p:NativeProcess = ProcessUtils.createProcess('C:/app.exe', ['-a']);
     * </listing>
     */
    public static function createProcess(path:String, arguments:Object = null):NativeProcess {
        if (!NativeProcess.isSupported) {
            trace('NativeProcess is not supported');

            return null;
        }

        var exeFile:File = new File(path);
        if (!exeFile.exists) {

            return null;
        }

        var argumentsVec:Vector.<String>;
        if (arguments) {
            argumentsVec = new Vector.<String>();
            if (arguments is String) {
                argumentsVec.push(arguments as String);
            }
            else if (arguments is Array) {
                for (var i:int = 0; i < arguments.length; i++) {
                    argumentsVec.push(arguments[i]);
                }
            }
        }

        var info:NativeProcessStartupInfo = new NativeProcessStartupInfo();
        info.executable = exeFile;
        info.arguments  = argumentsVec;

        var process:NativeProcess = new NativeProcess();
        process.start(info);
        trace('PC process is created');

        return process;
    }

    /**
     * 调用 CMD 执行命令。
     * @param cmd CMD 命令。
     * @param processLiveTime 进程存活时间（毫秒），默认 5000。
     * @param outputBack 输出回调，参数为累计输出字符串。
     * @param outputCheckTimeOut 无新输出后多少毫秒触发回调，默认 2000。
     * @return 是否成功启动进程。
     * @example
     * <listing version="3.0">
     * ProcessUtils.callCMD('dir', 3000, onOut);
     * </listing>
     */
    public static function callCMD(
            cmd                 :String,
            processLiveTime     :int = 5000,
            outputBack          :Function = null,
            outputCheckTimeOut  :int = 2000
    ):Boolean {
        trace('call cmd ::', cmd);
        cmd += '\n';

        var process:NativeProcess = createCMDProcess();
        if (!process) {

            return false;
        }

        process.standardInput.writeUTFBytes(cmd);

        if (outputBack != null) {
            var outputFinTimer:Timer = new Timer(outputCheckTimeOut, 1);
            var output:String        = '';

            outputFinTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function ():void {
                outputBack(output);
                setTimeout(closeProcess, processLiveTime);
            }, false, 0, true);

            process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, function (e:ProgressEvent):void {
                output += process.standardOutput.readUTFBytes(process.standardOutput.bytesAvailable);
                outputFinTimer.reset();
                outputFinTimer.start();
            }, false, 0, true);
        }
        else {
            setTimeout(closeProcess, processLiveTime);
        }

        return true;

        function closeProcess():void {
            try {
                process.exit();
            }
            catch (e:Error) {
            }
        }
    }

    /**
     * 强制结束指定进程。
     * @param processName 进程名称（如 <code>qq.exe</code>）。
     * @return 是否成功发起关闭命令。
     * @example
     * <listing version="3.0">
     * ProcessUtils.closeProcess('notepad.exe');
     * </listing>
     */
    public static function closeProcess(processName:String):Boolean {
        return callCMD('taskkill /f /t /im "' + processName + '"');
    }

    /**
     * 检查进程是否存在。
     * @param processName 进程名称（如 <code>qq.exe</code>）。
     * @param back 回调，参数为是否存在。
     * @return 是否成功启动查询命令。
     * @example
     * <listing version="3.0">
     * ProcessUtils.processExists('explorer.exe', onExist);
     * </listing>
     */
    public static function processExists(processName:String, back:Function):Boolean {
        function outputHandler(result:String):void {
            back(result.indexOf(processName) != -1);
        }

        return callCMD('tasklist', 2000, outputHandler);
    }

    /**
     * 打开应用程序。
     * @param path 完整路径。
     * @param initParam 启动参数。
     * @return 是否成功发起命令。
     * @example
     * <listing version="3.0">
     * ProcessUtils.openProgram('C:/app.exe', '-debug');
     * </listing>
     */
    public static function openProgram(path:String, initParam:String = null):Boolean {
        return callCMD('"' + path + '"' + (initParam ? ' ' + initParam : ''));
    }

    /**
     * 调用资源管理器打开指定目录。
     * @param folder 完整路径。
     * @return 是否成功发起命令。
     * @example
     * <listing version="3.0">
     * ProcessUtils.openExplorer('C:/temp');
     * </listing>
     */
    public static function openExplorer(folder:String):Boolean {
        return callCMD('explorer "' + folder + '"');
    }

    /**
     * 通过 CMD 执行 bat 文件。
     * @param filePath bat 完整路径。
     * @param exitBack 进程退出回调。
     * @return 是否成功启动进程。
     * @example
     * <listing version="3.0">
     * ProcessUtils.runBAT('C:/scripts/build.bat', onExit);
     * </listing>
     */
    public static function runBAT(filePath:String, exitBack:Function = null):Boolean {
        trace('run bat :: ' + filePath);
        return createCMDProcess(['/c', filePath], exitBack) != null;
    }

    /**
     * @private 启动 <code>cmd.exe</code>；可选监听退出。
     */
    private static function createCMDProcess(param:Object = null, exitBack:Function = null):NativeProcess {
        var process:NativeProcess = createProcess('c:/windows/system32/cmd.exe', param);
        if (!process) {
            return null;
        }

        if (exitBack != null) {
            process.addEventListener(NativeProcessExitEvent.EXIT, cmdExitHandler);
        }

        function cmdExitHandler(e:NativeProcessExitEvent):void {
            process.removeEventListener(NativeProcessExitEvent.EXIT, cmdExitHandler);
            if (exitBack != null) {
                exitBack();
            }
        }

        return process;
    }

}
}
