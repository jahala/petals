// file-off-brand.tsx — uses #3B82F6 which is NOT in the palette
// This should trigger a color audit error

export function Card() {
  return (
    <div style={{ backgroundColor: '#FFFFFF', borderRadius: '8px' }}>
      <h2 style={{ color: '#3B82F6' }}>Card Title</h2>
      <p style={{ color: '#585961' }}>This card uses an off-palette blue for its heading.</p>
      <button style={{ backgroundColor: '#3B82F6', color: '#FFFFFF' }}>
        Click Me
      </button>
    </div>
  );
}
