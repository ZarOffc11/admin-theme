@extends('layouts.admin')

@section('title')
    Administration Overview
@endsection

@section('content-header')
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons+Outlined" rel="stylesheet">
@endsection

@section('content')
@php
    $users = DB::table('users')->count();
    $servers = DB::table('servers')->count();
    $nodes = DB::table('nodes')->count();
    $provider = "ZarProject";

    // System Information
    $uptime = trim(shell_exec("uptime -p"));
    $cores = trim(shell_exec("nproc"));
    $load = sys_getloadavg();
    
    // RAM Information
    $ram_total = (int)trim(shell_exec("free -m | awk '/Mem:/ { print $2 }'"));
    $ram_used = (int)trim(shell_exec("free -m | awk '/Mem:/ { print $3 }'"));
    $ram_free = (int)trim(shell_exec("free -m | awk '/Mem:/ { print $4 }'"));
    $ram_percent = $ram_total > 0 ? round(($ram_used / $ram_total) * 100) : 0;
    
    // Disk Information
    $disk_total = trim(shell_exec("df -h / | awk 'NR==2 {print $2}'"));
    $disk_used = trim(shell_exec("df -h / | awk 'NR==2 {print $3}'"));
    $disk_free = trim(shell_exec("df -h / | awk 'NR==2 {print $4}'"));
    $disk_used_perc = trim(shell_exec("df -h / | awk 'NR==2 {print $5}'"));
    $disk_percent = (int)str_replace('%', '', $disk_used_perc);
    
    // Additional System Info
    $os = trim(shell_exec("cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"'"));
    $kernel = trim(shell_exec("uname -r"));
    $hostname = trim(shell_exec("hostname"));
    $php_version = phpversion();
    
    // Panel Version
    $panel_version = config('app.version', '1.0.0');
@endphp

<style>
    /* --- GLOBAL DYNAMIC THEME --- */
    .content-wrapper, body {
        background-color: var(--bg-app) !important;
        background-image: 
            linear-gradient(var(--grid-line) 1px, transparent 1px),
            linear-gradient(90deg, var(--grid-line) 1px, transparent 1px) !important;
        background-size: 40px 40px !important;
        background-position: -1px -1px !important;
        color: var(--text-main) !important;
        transition: background-color 0.3s ease, color 0.3s ease;
    }

    /* Override Header Text */
    .content-header > h1 {
        color: var(--text-main) !important;
        font-weight: 700 !important;
    }
    .content-header > h1 > small {
        color: var(--text-sub) !important;
    }
    .breadcrumb {
        background: transparent !important;
    }
    .breadcrumb li a {
        color: #6366f1 !important;
    }
    .breadcrumb li.active {
        color: var(--text-sub) !important;
    }

    /* --- NEBULA CARDS (DYNAMIC) --- */
    .nebula-card {
        background: var(--bg-card) !important;
        border: 1px solid var(--border-color) !important;
        border-radius: 16px !important;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06) !important;
        padding: 20px;
        margin-bottom: 25px;
        position: relative;
        overflow: hidden;
        transition: transform 0.3s ease, background 0.3s ease, border-color 0.3s ease;
    }
    .nebula-card:hover {
        transform: translateY(-5px);
        border-color: rgba(99, 102, 241, 0.5) !important;
    }
    
    .nebula-card::after {
        content: '';
        position: absolute;
        top: -50px; right: -50px;
        width: 100px; height: 100px;
        background: radial-gradient(circle, rgba(99,102,241,0.1) 0%, transparent 70%);
        border-radius: 50%;
        filter: blur(20px);
        pointer-events: none;
    }

    /* --- STATS BOXES --- */
    .stat-box {
        display: flex;
        align-items: center;
        justify-content: space-between;
    }
    .stat-content h3 {
        font-size: 28px;
        font-weight: 800;
        margin: 0;
        color: var(--text-main);
    }
    .stat-content p {
        margin: 0;
        font-size: 13px;
        color: var(--text-sub);
        text-transform: uppercase;
        letter-spacing: 0.5px;
        font-weight: 600;
    }
    .stat-icon {
        width: 50px;
        height: 50px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .stat-icon .material-icons-outlined {
        font-size: 24px;
    }
    
    .icon-primary { background: rgba(99, 102, 241, 0.1); color: #818cf8; border: 1px solid rgba(99, 102, 241, 0.2); }
    .icon-success { background: rgba(34, 197, 94, 0.1); color: #4ade80; border: 1px solid rgba(34, 197, 94, 0.2); }
    .icon-warning { background: rgba(245, 158, 11, 0.1); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.2); }
    .icon-danger  { background: rgba(239, 68, 68, 0.1); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.2); }

    /* --- SECTION HEADERS --- */
    .section-header {
        display: flex;
        align-items: center;
        margin-bottom: 20px;
        border-bottom: 1px solid var(--border-color);
        padding-bottom: 15px;
    }
    .section-header .material-icons-outlined {
        margin-right: 10px;
        color: #6366f1;
    }
    .section-header h3 {
        margin: 0;
        font-size: 18px;
        font-weight: 600;
        color: var(--text-main);
    }

    /* --- PROGRESS BARS --- */
    .resource-item { margin-bottom: 25px; }
    .resource-meta {
        display: flex;
        justify-content: space-between;
        margin-bottom: 8px;
        font-size: 13px;
        color: var(--text-sub);
    }
    .resource-value { font-weight: 700; color: var(--text-main); }
    
    .progress-track {
        background: var(--input-bg);
        border: 1px solid var(--border-color);
        height: 8px;
        border-radius: 10px;
        overflow: hidden;
    }
    .progress-bar-custom {
        height: 100%;
        border-radius: 10px;
        background: linear-gradient(90deg, #6366f1, #a855f7);
        transition: width 0.5s ease;
    }
    .bar-green { background: linear-gradient(90deg, #22c55e, #4ade80); }
    .bar-orange { background: linear-gradient(90deg, #f97316, #fb923c); }
    .bar-red { background: linear-gradient(90deg, #ef4444, #f87171); }

    /* --- SPECS LIST --- */
    .specs-list {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
        gap: 15px;
    }
    .spec-box {
        background: var(--input-bg);
        padding: 15px;
        border-radius: 12px;
        border: 1px solid var(--border-color);
        text-align: center;
        transition: background 0.3s ease;
    }
    .spec-icon-small {
        color: #6366f1;
        margin-bottom: 8px;
    }
    .spec-label-small {
        font-size: 11px;
        color: var(--text-sub);
        text-transform: uppercase;
        margin-bottom: 4px;
    }
    .spec-value-small {
        font-size: 13px;
        font-weight: 600;
        color: var(--text-main);
        word-break: break-all;
    }

    /* --- DETAILS LIST --- */
    .detail-item {
        display: flex;
        justify-content: space-between;
        padding: 12px 0;
        border-bottom: 1px solid var(--border-color);
    }
    .detail-label {
        color: var(--text-sub);
        display: flex;
        align-items: center;
    }
    .detail-label .material-icons-outlined {
        font-size: 18px;
        margin-right: 8px;
        color: #6366f1;
    }
    .detail-value {
        color: var(--text-main);
        font-family: monospace;
        font-weight: 600;
    }

    /* --- OVERRIDE ADMINLTE ROW --- */
    .row { margin-left: -10px; margin-right: -10px; }
    .col-lg-3, .col-md-6, .col-md-8, .col-md-4, .col-sm-3 { padding-left: 10px; padding-right: 10px; }

</style>

<div class="row">
    <div class="col-lg-3 col-md-6 col-sm-6 col-xs-12">
        <div class="nebula-card stat-box">
            <div class="stat-content">
                <h3 id="stat-users">{{ number_format($users) }}</h3>
                <p>Total Pengguna</p>
            </div>
            <div class="stat-icon icon-primary">
                <span class="material-icons-outlined">people</span>
            </div>
        </div>
    </div>

    <div class="col-lg-3 col-md-6 col-sm-6 col-xs-12">
        <div class="nebula-card stat-box">
            <div class="stat-content">
                <h3 id="stat-servers">{{ number_format($servers) }}</h3>
                <p>Server Aktif</p>
            </div>
            <div class="stat-icon icon-success">
                <span class="material-icons-outlined">dns</span>
            </div>
        </div>
    </div>

    <div class="col-lg-3 col-md-6 col-sm-6 col-xs-12">
        <div class="nebula-card stat-box">
            <div class="stat-content">
                <h3 id="stat-nodes">{{ number_format($nodes) }}</h3>
                <p>Node Aktif</p>
            </div>
            <div class="stat-icon icon-warning">
                <span class="material-icons-outlined">hub</span>
            </div>
        </div>
    </div>

    <div class="col-lg-3 col-md-6 col-sm-6 col-xs-12">
        <div class="nebula-card stat-box">
            <div class="stat-content">
                <h3 style="font-size: 20px; line-height: 28px;">{{ $provider }}</h3>
                <p>Creator</p>
            </div>
            <div class="stat-icon icon-danger">
                <span class="material-icons-outlined">logo_dev</span>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-md-8">
        <div class="nebula-card" style="height: 100%;">
            <div class="section-header">
                <span class="material-icons-outlined">pie_chart</span>
                <h3>Resource Monitor</h3>
            </div>
            
            <div class="row">
                <div class="col-md-12">
                    <div class="resource-item">
                        <div class="resource-meta">
                            <span style="display:flex; align-items:center;">
                                <span class="material-icons-outlined" style="font-size:16px; margin-right:5px;">memory</span>
                                CPU Load
                            </span>
                            <span class="resource-value text-{{ $load[0] > 3 ? 'danger' : 'success' }}" id="res-cpu-text">
                                {{ $load[0] }} <small class="text-muted">/ {{ $cores }} threads</small>
                            </span>
                        </div>
                        <div class="progress-track">
                            @php $cpu_percent = min($load[0] * 20, 100); @endphp
                            <div id="res-cpu-bar" class="progress-bar-custom {{ $cpu_percent > 80 ? 'bar-red' : ($cpu_percent > 50 ? 'bar-orange' : '') }}" 
                                 style="width: {{ $cpu_percent }}%"></div>
                        </div>
                    </div>

                    <div class="resource-item">
                        <div class="resource-meta">
                            <span style="display:flex; align-items:center;">
                                <span class="material-icons-outlined" style="font-size:16px; margin-right:5px;">sd_storage</span>
                                RAM Usage
                            </span>
                            <span class="resource-value text-{{ $ram_percent > 85 ? 'danger' : 'success' }}" id="res-ram-text">
                                {{ number_format($ram_used) }}MB <small class="text-muted">/ {{ number_format($ram_total) }}MB</small>
                            </span>
                        </div>
                        <div class="progress-track">
                            <div id="res-ram-bar" class="progress-bar-custom {{ $ram_percent > 85 ? 'bar-red' : ($ram_percent > 60 ? 'bar-orange' : 'bar-green') }}" 
                                 style="width: {{ $ram_percent }}%"></div>
                        </div>
                    </div>

                    <div class="resource-item">
                        <div class="resource-meta">
                            <span style="display:flex; align-items:center;">
                                <span class="material-icons-outlined" style="font-size:16px; margin-right:5px;">storage</span>
                                Disk Usage
                            </span>
                            <span class="resource-value text-{{ $disk_percent > 85 ? 'danger' : 'success' }}" id="res-disk-text">
                                {{ $disk_used }} <small class="text-muted">/ {{ $disk_total }}</small>
                            </span>
                        </div>
                        <div class="progress-track">
                            <div id="res-disk-bar" class="progress-bar-custom {{ $disk_percent > 85 ? 'bar-red' : ($disk_percent > 60 ? 'bar-orange' : '') }}" 
                                 style="width: {{ $disk_percent }}%"></div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="specs-list mt-4">
                <div class="spec-box">
                    <div class="spec-icon-small"><span class="material-icons-outlined">terminal</span></div>
                    <div class="spec-label-small">OS Distro</div>
                    <div class="spec-value-small">{{ Str::limit($os, 15) }}</div>
                </div>
                <div class="spec-box">
                    <div class="spec-icon-small"><span class="material-icons-outlined">settings_suggest</span></div>
                    <div class="spec-label-small">Kernel</div>
                    <div class="spec-value-small">{{ $kernel }}</div>
                </div>
                <div class="spec-box">
                    <div class="spec-icon-small"><span class="material-icons-outlined">schedule</span></div>
                    <div class="spec-label-small">Uptime</div>
                    <div class="spec-value-small" id="sys-uptime">{{ Str::words($uptime, 3, '') }}</div>
                </div>
                <div class="spec-box">
                    <div class="spec-icon-small"><span class="material-icons-outlined">code</span></div>
                    <div class="spec-label-small">PHP</div>
                    <div class="spec-value-small">{{ $php_version }}</div>
                </div>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="nebula-card">
            <div class="section-header">
                <span class="material-icons-outlined">storage</span>
                <h3>System Details</h3>
            </div>
            
            <ul style="list-style: none; padding: 0; margin: 0;">
                <li class="detail-item">
                    <span class="detail-label">
                        <span class="material-icons-outlined">computer</span> Hostname
                    </span>
                    <span class="detail-value">{{ $hostname }}</span>
                </li>
                <li class="detail-item">
                    <span class="detail-label">
                        <span class="material-icons-outlined">integration_instructions</span> Panel Ver.
                    </span>
                    <span class="detail-value">{{ $panel_version }}</span>
                </li>
                <li class="detail-item">
                    <span class="detail-label">
                        <span class="material-icons-outlined">memory</span> Free RAM
                    </span>
                    <span class="detail-value" style="color: #4ade80;" id="sys-freeram">{{ number_format($ram_free) }} MB</span>
                </li>
                <li class="detail-item">
                    <span class="detail-label">
                        <span class="material-icons-outlined">disc_full</span> Free Disk
                    </span>
                    <span class="detail-value" style="color: #4ade80;" id="sys-freedisk">{{ $disk_free }}</span>
                </li>
                <li class="detail-item" style="border-bottom: none;">
                    <span class="detail-label">
                        <span class="material-icons-outlined">access_time</span> Time
                    </span>
                    <span class="detail-value" id="sys-time">{{ date('H:i') }}</span>
                </li>
            </ul>

            <div id="sys-status-box" style="margin-top: 20px; padding: 15px; background: rgba(99, 102, 241, 0.1); border-radius: 12px; border: 1px solid rgba(99, 102, 241, 0.2); text-align: center;">
                <small style="color: #818cf8; font-weight: 600;">System Status</small>
                <div id="sys-status-text" style="font-size: 18px; font-weight: bold; margin-top: 5px; color: {{ ($load[0] > 3 || $ram_percent > 90) ? '#f87171' : '#4ade80' }}">
                    {{ ($load[0] > 3 || $ram_percent > 90) ? 'HEAVY LOAD' : 'OPERATIONAL' }}
                </div>
            </div>
        </div>
    </div>
</div>

{{-- SCRIPT AUTO UPDATE (2 DETIK) --}}
<script>
    setInterval(function() {
        fetch(window.location.href)
            .then(response => response.text())
            .then(html => {
                const parser = new DOMParser();
                const doc = parser.parseFromString(html, 'text/html');

                // Helper function to update content safely
                const updateText = (id) => {
                    const newEl = doc.getElementById(id);
                    const oldEl = document.getElementById(id);
                    if (newEl && oldEl) oldEl.innerHTML = newEl.innerHTML;
                };

                const updateClassAndStyle = (id) => {
                    const newEl = doc.getElementById(id);
                    const oldEl = document.getElementById(id);
                    if (newEl && oldEl) {
                        oldEl.className = newEl.className;
                        oldEl.style.cssText = newEl.style.cssText;
                    }
                };

                // Update Stats
                updateText('stat-users');
                updateText('stat-servers');
                updateText('stat-nodes');

                // Update Resources (Text & Bar)
                updateText('res-cpu-text');
                updateClassAndStyle('res-cpu-bar');

                updateText('res-ram-text');
                updateClassAndStyle('res-ram-bar');

                updateText('res-disk-text');
                updateClassAndStyle('res-disk-bar');

                // Update System Info
                updateText('sys-uptime');
                updateText('sys-freeram');
                updateText('sys-freedisk');
                updateText('sys-time');

                // Update Status Box
                updateText('sys-status-text');
                const newStatusText = doc.getElementById('sys-status-text');
                const oldStatusText = document.getElementById('sys-status-text');
                if (newStatusText && oldStatusText) {
                     oldStatusText.style.color = newStatusText.style.color;
                }
            })
            .catch(err => console.error('Failed to update stats:', err));
    }, 2000); // 2000ms = 2 Detik
</script>
@endsection
