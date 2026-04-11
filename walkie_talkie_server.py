import socket
import threading

# Configuration
HOST = '127.0.0.1'  # Localhost
PORT = 65432        # Port to listen on

# List to keep track of connected AutoIt clients
clients = []

def handle_client(conn, addr):
    print(f"[NEW CONNECTION] {addr} connected.")
    clients.append(conn)
    try:
        while True:
            # Receive data from the client
            data = conn.recv(1024)
            if not data:
                break
            
            message = data.decode('utf-8')
            print(f"[{addr}] Received: {message}")
            
            # Broadcast the received variable/message to all OTHER clients
            for c in clients:
                if c != conn:
                    try:
                        c.sendall(data)
                    except Exception as e:
                        print(f"Error sending to a client: {e}")
    except ConnectionResetError:
        pass
    finally:
        print(f"[DISCONNECTED] {addr} disconnected.")
        if conn in clients:
            clients.remove(conn)
        conn.close()

def start_server():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.bind((HOST, PORT))
    server.listen()
    print(f"[LISTENING] Python Walkie-Talkie Server is listening on {HOST}:{PORT}")
    
    try:
        while True:
            conn, addr = server.accept()
            # Handle each new AutoIt script in a separate thread
            thread = threading.Thread(target=handle_client, args=(conn, addr))
            thread.start()
    except KeyboardInterrupt:
        print("\n[SHUTTING DOWN] Server is stopping.")
    finally:
        server.close()

if __name__ == "__main__":
    start_server()
