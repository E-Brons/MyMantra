import React from 'react';
import { Outlet, useLocation, useNavigate } from 'react-router';
import { Home, BookOpen, BarChart3, Settings, Library } from 'lucide-react';

const NAV_ITEMS = [
  { path: '/', label: 'Mantras', icon: Home },
  { path: '/library', label: 'Library', icon: Library },
  { path: '/progress', label: 'Progress', icon: BarChart3 },
  { path: '/settings', label: 'Settings', icon: Settings },
];

export function Layout() {
  const location = useLocation();
  const navigate = useNavigate();

  // Hide bottom nav on session screen
  const isSession = location.pathname.includes('/session');

  return (
    <div className="min-h-screen bg-background flex justify-center">
      <div
        className="relative flex flex-col w-full max-w-[430px] min-h-screen overflow-hidden"
        style={{ fontFamily: "'Inter', 'Noto Sans Devanagari', sans-serif" }}
      >
        {/* Page content */}
        <main className={`flex-1 overflow-y-auto ${isSession ? '' : 'pb-20'}`}>
          <Outlet />
        </main>

        {/* Bottom Navigation */}
        {!isSession && (
          <nav
            className="fixed bottom-0 left-1/2 -translate-x-1/2 w-full max-w-[430px] z-50"
            style={{
              background: 'var(--nav-bg, rgba(15, 12, 26, 0.96))',
              backdropFilter: 'blur(20px)',
              WebkitBackdropFilter: 'blur(20px)',
              borderTop: '1px solid rgba(139, 92, 246, 0.15)',
            }}
          >
            <div className="flex items-center justify-around px-2 py-2 safe-area-bottom">
              {NAV_ITEMS.map(({ path, label, icon: Icon }) => {
                const isActive =
                  path === '/'
                    ? location.pathname === '/'
                    : location.pathname.startsWith(path);

                return (
                  <button
                    key={path}
                    onClick={() => navigate(path)}
                    className={`flex flex-col items-center gap-1 px-4 py-2 rounded-2xl transition-all duration-200 ${
                      isActive
                        ? 'text-violet-400'
                        : 'text-muted-foreground hover:text-foreground'
                    }`}
                  >
                    <div
                      className={`p-1.5 rounded-xl transition-all duration-200 ${
                        isActive ? 'bg-violet-500/20' : ''
                      }`}
                    >
                      <Icon
                        size={22}
                        strokeWidth={isActive ? 2.5 : 1.8}
                        className="transition-all duration-200"
                      />
                    </div>
                    <span
                      className={`text-[10px] transition-all duration-200 ${
                        isActive ? 'opacity-100' : 'opacity-60'
                      }`}
                    >
                      {label}
                    </span>
                  </button>
                );
              })}
            </div>
          </nav>
        )}
      </div>
    </div>
  );
}
