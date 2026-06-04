// file-on-brand.tsx — uses only palette colors
// All hex values are from the brand-check test palette

export function Header() {
  return (
    <header style={{ backgroundColor: '#FFFFFF', color: '#585961' }}>
      <h1 style={{ color: '#2F99A4' }}>Welcome</h1>
      <button style={{ backgroundColor: '#FF4D00', color: '#FFFFFF' }}>
        Get Started
      </button>
    </header>
  );
}

export function Alert() {
  return (
    <div style={{ borderColor: '#F0C040', color: '#585961' }}>
      <p>Important update available.</p>
    </div>
  );
}

export function SuccessMessage() {
  return (
    <div style={{ backgroundColor: '#47B881', color: '#FFFFFF' }}>
      Operation completed successfully.
    </div>
  );
}
