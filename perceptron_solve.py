"""
1D Perceptron CTF Solver
=========================
Challenge: nc aureolin-pixie.cylabacademy.net 63375

A 1D perceptron: f(x) = sign(w*x + b)
Decision boundary at: x = -b/w

Modes:
  python perceptron_solve.py          # auto-connect to server
  python perceptron_solve.py manual   # paste server output, get w & b
"""
import socket
import re
import sys


def solve(points):
    """Given (x, label) pairs, return (w, b) that separates them."""
    labels = sorted(set(lbl for _, lbl in points))
    if len(labels) != 2:
        raise ValueError(f"Need exactly 2 labels, got: {labels}")

    left_label, right_label = labels[0], labels[1]

    left_pts  = sorted([x for x, lbl in points if lbl == left_label])
    right_pts = sorted([x for x, lbl in points if lbl == right_label])

    # Determine which class is actually on the left
    if max(left_pts) < min(right_pts):
        # left_label is truly on the left
        threshold = (max(left_pts) + min(right_pts)) / 2.0
        # sign(x - threshold): right_label gets +1, left_label gets -1
        # Need to map to actual labels. If left_label == -1 and right_label == +1, we're good.
        # If labels are 0/1 or reversed, we still just need a working separation.
        w = 1.0
        b = -threshold
    elif max(right_pts) < min(left_pts):
        # right_label is actually on the left, left_label on the right
        threshold = (max(right_pts) + min(left_pts)) / 2.0
        w = -1.0
        b = threshold
    else:
        raise ValueError(
            f"Classes overlap! {left_label}: {left_pts}, {right_label}: {right_pts}"
        )

    # Verify
    ok = True
    for x, lbl in points:
        pred = 1 if w * x + b > 0 else -1
        if pred != lbl:
            ok = False
            break

    return w, b, threshold, ok


def parse_points(text):
    """Extract (x, label) from server output text."""
    points = []

    # Try to find labeled points: a float, then a label (int)
    # Look for patterns like "2.5" near "1" or "-1"
    lines = text.strip().split('\n')

    for line in lines:
        nums = re.findall(r'[-+]?\d+\.?\d*', line)
        if len(nums) >= 2:
            try:
                x = float(nums[0])
                lbl = float(nums[-1])
                lbl = int(lbl) if lbl == int(lbl) else lbl
                points.append((x, lbl))
            except ValueError:
                pass

    return points


def manual_mode():
    """Paste server output here, get w and b to send back."""
    print("Paste the server output (Ctrl+Z then Enter on Windows, Ctrl+D on Linux/Mac):")
    lines = []
    try:
        while True:
            line = input()
            lines.append(line)
    except EOFError:
        pass

    text = '\n'.join(lines)
    points = parse_points(text)

    if not points:
        print("[!] Couldn't parse points. Try pasting raw data again.")
        print("[!] Or enter points manually:")
        print("    Format: x label  (one per line, blank line to finish)")
        points = []
        while True:
            line = input()
            if not line.strip():
                break
            parts = line.strip().split()
            if len(parts) >= 2:
                points.append((float(parts[0]), float(parts[1])))

    print(f"\n[+] Parsed {len(points)} points")
    for x, lbl in points:
        print(f"    x={x:8.3f}  label={lbl}")

    try:
        w, b, threshold, ok = solve(points)
        print(f"\n[+] Threshold = {threshold:.6f}")
        print(f"[+] w = {w}, b = {b}")
        print(f"[+] Verification: {'ALL CORRECT' if ok else 'SOME WRONG'}")

        print(f"\n>>> Send this to the server: {w} {b}")
    except ValueError as e:
        print(f"\n[!] Error: {e}")


def auto_mode():
    """Connect to the CTF server automatically."""
    host = 'aureolin-pixie.cylabacademy.net'
    port = 63375

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(30)

    try:
        print(f"[*] Connecting to {host}:{port}...")
        sock.connect((host, port))
        print("[+] Connected!\n")

        round_num = 0
        buffer = b''

        while True:
            sock.settimeout(5)
            try:
                chunk = sock.recv(4096)
                if not chunk:
                    break
                buffer += chunk
            except socket.timeout:
                pass

            text = buffer.decode('utf-8', errors='replace')
            print(f"--- Round {round_num} ---")
            print(text)

            # Check for flag
            flag_match = re.search(r'flag\{[^}]+\}', text, re.IGNORECASE)
            if flag_match:
                print(f"\n[FLAG] {flag_match.group(0)}")
                break

            points = parse_points(text)

            if points:
                try:
                    w, b, threshold, ok = solve(points)
                    answer = f"{w} {b}"
                    print(f"\n[*] Sending: {answer}")
                    sock.send((answer + '\n').encode())
                    buffer = b''
                    round_num += 1
                except ValueError as e:
                    print(f"[!] {e}")
                    break
            else:
                # No points found - maybe it's asking for initial input
                # or maybe flag was already received
                if 'flag' in text.lower():
                    break

                # Interactive fallback
                print("[?] Couldn't auto-parse. Enter 'w b' manually (or 'q'):")
                user = input("> ")
                if user.lower() == 'q':
                    break
                sock.send((user + '\n').encode())
                buffer = b''

    except socket.timeout:
        print("[!] Connection timed out")
    except ConnectionRefusedError:
        print("[!] Connection refused")
    except Exception as e:
        print(f"[!] Error: {type(e).__name__}: {e}")
    finally:
        sock.close()


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == 'manual':
        manual_mode()
    else:
        auto_mode()
