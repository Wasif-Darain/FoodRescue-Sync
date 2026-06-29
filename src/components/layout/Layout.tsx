import type { ReactNode } from 'react';
import { Sidebar } from './Sidebar';

interface LayoutProps {
  children: ReactNode;
  title?: string;
  subtitle?: string;
  actions?: ReactNode;
}

export function Layout({ children, title, subtitle, actions }: LayoutProps) {
  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="ml-60 flex-1 min-h-screen">
        {(title || actions) && (
          <div className="bg-white border-b border-gray-100 px-8 py-5">
            <div className="flex items-center justify-between">
              <div>
                {title && <h1 className="text-xl font-bold text-gray-900">{title}</h1>}
                {subtitle && <p className="text-sm text-gray-500 mt-0.5">{subtitle}</p>}
              </div>
              {actions && <div className="flex items-center gap-3">{actions}</div>}
            </div>
          </div>
        )}
        <div className="p-8">
          {children}
        </div>
      </main>
    </div>
  );
}
