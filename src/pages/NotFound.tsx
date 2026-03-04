import React from 'react';
import { useNavigate } from 'react-router';

export function NotFound() {
  const navigate = useNavigate();
  return (
    <div className="flex flex-col items-center justify-center min-h-screen text-center px-8">
      <div style={{ fontSize: '64px', lineHeight: 1 }}>🙏</div>
      <h2 className="text-foreground mt-4" style={{ fontSize: '22px', fontWeight: 600 }}>
        Page Not Found
      </h2>
      <p className="text-muted-foreground mt-2 mb-6" style={{ fontSize: '14px' }}>
        The path you seek does not exist. Return to your practice.
      </p>
      <button
        onClick={() => navigate('/')}
        className="px-6 py-3 rounded-xl text-white"
        style={{ background: 'linear-gradient(135deg, #7c3aed, #6d28d9)', fontSize: '15px' }}
      >
        Go Home
      </button>
    </div>
  );
}
